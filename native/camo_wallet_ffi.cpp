// Copyright (c) 2026, The CAMO Project. BSD-3-Clause, see LICENSE.
// See camo_wallet_ffi.h. Glue only: all wallet logic is CAMO's libwallet (wallet2_api.h).
#include "camo_wallet_ffi.h"
#include "wallet/api/wallet2_api.h"

#include <mutex>
#include <sstream>
#include <string>

using namespace Monero;

struct camo_wallet {
  Wallet *w = nullptr;
  PendingTransaction *pending = nullptr;
  std::string scratch; // backing store for returned strings
  std::mutex lock;
};

static thread_local std::string g_last_error;

static WalletManager *mgr() { return WalletManagerFactory::getWalletManager(); }
static NetworkType net(int n) { return n == 1 ? TESTNET : n == 2 ? STAGENET : MAINNET; }

static camo_wallet *wrap(Wallet *w) {
  if (!w) {
    g_last_error = mgr()->errorString();
    return nullptr;
  }
  if (w->status() != Wallet::Status_Ok) {
    g_last_error = w->errorString();
    mgr()->closeWallet(w, false);
    return nullptr;
  }
  auto *cw = new camo_wallet();
  cw->w = w;
  return cw;
}

static const char *ret(camo_wallet *cw, std::string s) {
  cw->scratch = std::move(s);
  return cw->scratch.c_str();
}

extern "C" {

const char *camo_version(void) { return "camo-wallet-ffi 1"; } // bridge version; the library version comes from the camo build

int camo_wallet_exists(const char *path) { return mgr()->walletExists(path) ? 1 : 0; }
int camo_address_valid(const char *address, int network) { return Wallet::addressValid(address, net(network)) ? 1 : 0; }
const char *camo_last_error(void) { return g_last_error.c_str(); }

camo_wallet *camo_wallet_create(const char *path, const char *password, const char *language, int network) {
  return wrap(mgr()->createWallet(path, password, language ? language : "English", net(network)));
}

camo_wallet *camo_wallet_restore_seed(const char *path, const char *password, const char *seed25, int network,
                                      uint64_t restore_height) {
  return wrap(mgr()->recoveryWallet(path, password, seed25, net(network), restore_height));
}

camo_wallet *camo_wallet_open(const char *path, const char *password, int network) {
  return wrap(mgr()->openWallet(path, password, net(network)));
}

int camo_wallet_close(camo_wallet *cw, int store) {
  if (!cw) return 0;
  if (cw->pending) cw->w->disposeTransaction(cw->pending);
  const bool ok = mgr()->closeWallet(cw->w, store != 0);
  delete cw;
  return ok ? 1 : 0;
}

const char *camo_wallet_error(camo_wallet *cw) { return ret(cw, cw->w->errorString()); }
const char *camo_wallet_seed(camo_wallet *cw) { return ret(cw, cw->w->seed()); }
const char *camo_wallet_address(camo_wallet *cw, uint32_t i) { return ret(cw, cw->w->address(0, i)); }
uint32_t camo_wallet_num_subaddresses(camo_wallet *cw) { return static_cast<uint32_t>(cw->w->numSubaddresses(0)); }
int camo_wallet_add_subaddress(camo_wallet *cw, const char *label) {
  cw->w->addSubaddress(0, label ? label : "");
  return 1;
}
const char *camo_wallet_subaddress_label(camo_wallet *cw, uint32_t i) { return ret(cw, cw->w->getSubaddressLabel(0, i)); }
int camo_wallet_set_subaddress_label(camo_wallet *cw, uint32_t i, const char *label) {
  cw->w->setSubaddressLabel(0, i, label ? label : "");
  return 1;
}

int camo_wallet_connect(camo_wallet *cw, const char *daemon, int trusted) {
  if (!cw->w->init(daemon)) return 0;
  cw->w->setTrustedDaemon(trusted != 0); // remote nodes stay untrusted: the library then hides real spends among decoys it picks itself
  return 1;
}
int camo_wallet_start_refresh(camo_wallet *cw) {
  cw->w->startRefresh();
  return 1;
}
int camo_wallet_refresh_now(camo_wallet *cw) { return cw->w->refresh() ? 1 : 0; }
uint64_t camo_wallet_height(camo_wallet *cw) { return cw->w->blockChainHeight(); }
uint64_t camo_wallet_daemon_height(camo_wallet *cw) { return cw->w->daemonBlockChainHeight(); }
int camo_wallet_connected(camo_wallet *cw) { return cw->w->connected() == Wallet::ConnectionStatus_Connected ? 1 : 0; }
int camo_wallet_synchronized(camo_wallet *cw) { return cw->w->synchronized() ? 1 : 0; }
uint64_t camo_wallet_balance(camo_wallet *cw) { return cw->w->balance(0); }
uint64_t camo_wallet_unlocked_balance(camo_wallet *cw) { return cw->w->unlockedBalance(0); }
int camo_wallet_store(camo_wallet *cw) { return cw->w->store("") ? 1 : 0; }

int camo_wallet_history_refresh(camo_wallet *cw) {
  cw->w->history()->refresh();
  return 1;
}
int camo_wallet_history_count(camo_wallet *cw) { return cw->w->history()->count(); }
const char *camo_wallet_history_row(camo_wallet *cw, int i) {
  TransactionInfo *t = cw->w->history()->transaction(i);
  if (!t) return nullptr;
  std::ostringstream s;
  s << (t->direction() == TransactionInfo::Direction_In ? 0 : 1) << '|' << t->amount() << '|' << t->fee() << '|'
    << static_cast<int64_t>(t->timestamp()) << '|' << t->confirmations() << '|' << t->hash() << '|'
    << (t->isCoinbase() ? 1 : 0);
  return ret(cw, s.str());
}

int camo_wallet_prepare(camo_wallet *cw, const char *address, uint64_t amount, int sweep_all, int priority) {
  camo_wallet_discard(cw);
  const auto prio = priority == 3 ? PendingTransaction::Priority_High
                  : priority == 1 ? PendingTransaction::Priority_Low
                                  : PendingTransaction::Priority_Medium;
  // mixin 0 = the library's default ring size (16, enforced by consensus)
  cw->pending = cw->w->createTransaction(address, "", sweep_all ? optional<uint64_t>() : optional<uint64_t>(amount), 0, prio);
  if (!cw->pending || cw->pending->status() != PendingTransaction::Status_Ok) {
    g_last_error = cw->pending ? cw->pending->errorString() : cw->w->errorString();
    camo_wallet_discard(cw);
    return 0;
  }
  return 1;
}
uint64_t camo_wallet_prepared_fee(camo_wallet *cw) { return cw->pending ? cw->pending->fee() : 0; }
uint64_t camo_wallet_prepared_amount(camo_wallet *cw) { return cw->pending ? cw->pending->amount() : 0; }
const char *camo_wallet_commit(camo_wallet *cw) {
  if (!cw->pending) return nullptr;
  if (!cw->pending->commit()) {
    g_last_error = cw->pending->errorString();
    return nullptr;
  }
  std::string ids;
  for (const auto &id : cw->pending->txid()) ids += (ids.empty() ? "" : ",") + id;
  camo_wallet_discard(cw);
  cw->w->store("");
  return ret(cw, ids);
}
void camo_wallet_discard(camo_wallet *cw) {
  if (cw->pending) cw->w->disposeTransaction(cw->pending);
  cw->pending = nullptr;
}

} // extern "C"
