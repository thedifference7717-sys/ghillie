// Copyright (c) 2026, The CAMO Project. BSD-3-Clause, see LICENSE.
//
// Plain C bridge from the Ghillie app (Dart, via dart:ffi) to CAMO's wallet library
// (src/wallet/api/wallet2_api.h in the camo repository). Glue only: every cryptographic step
// (keys, addresses, ring/decoy selection, transaction building and signing) happens inside
// that library, unchanged. Amounts are atomic units (1 CAMO = 10^12) as uint64.
//
// Strings returned by camo_* functions are owned by the bridge and stay valid until the next
// call on the same wallet; copy them on the Dart side. Functions returning int: 1 = ok, 0 = error,
// then camo_wallet_error() explains.
#ifndef CAMO_WALLET_FFI_H
#define CAMO_WALLET_FFI_H
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct camo_wallet camo_wallet;

/* network: 0 mainnet, 1 testnet, 2 stagenet (same numbering as the library) */
const char *camo_version(void);
int camo_wallet_exists(const char *path);
int camo_address_valid(const char *address, int network);

/* create / restore / open; NULL on failure (call camo_last_error) */
camo_wallet *camo_wallet_create(const char *path, const char *password, const char *language, int network);
camo_wallet *camo_wallet_restore_seed(const char *path, const char *password, const char *seed25,
                                      int network, uint64_t restore_height);
camo_wallet *camo_wallet_open(const char *path, const char *password, int network);
const char *camo_last_error(void);
int camo_wallet_close(camo_wallet *w, int store);

const char *camo_wallet_error(camo_wallet *w);
const char *camo_wallet_seed(camo_wallet *w); /* shown once at creation, behind a warning */
const char *camo_wallet_address(camo_wallet *w, uint32_t subaddress_index);
uint32_t camo_wallet_num_subaddresses(camo_wallet *w);
int camo_wallet_add_subaddress(camo_wallet *w, const char *label);
const char *camo_wallet_subaddress_label(camo_wallet *w, uint32_t index);
int camo_wallet_set_subaddress_label(camo_wallet *w, uint32_t index, const char *label);

/* node and sync */
int camo_wallet_connect(camo_wallet *w, const char *daemon_address, int trusted);
int camo_wallet_start_refresh(camo_wallet *w); /* background refresh thread in the library */
int camo_wallet_refresh_now(camo_wallet *w);
uint64_t camo_wallet_height(camo_wallet *w);
uint64_t camo_wallet_daemon_height(camo_wallet *w);
int camo_wallet_connected(camo_wallet *w);
int camo_wallet_synchronized(camo_wallet *w);
uint64_t camo_wallet_balance(camo_wallet *w);
uint64_t camo_wallet_unlocked_balance(camo_wallet *w);
int camo_wallet_store(camo_wallet *w);

/* history: refresh, then read rows 0..count-1 (newest first) */
int camo_wallet_history_refresh(camo_wallet *w);
int camo_wallet_history_count(camo_wallet *w);
/* one row as "direction|amount|fee|timestamp|confirmations|txid|is_coinbase", direction 0 in / 1 out */
const char *camo_wallet_history_row(camo_wallet *w, int i);

/* send: prepare builds the transaction (nothing leaves the phone), commit broadcasts it.
   priority: 1 low, 2 normal, 3 fast. sweep_all != 0 sends the whole unlocked balance. */
int camo_wallet_prepare(camo_wallet *w, const char *address, uint64_t amount, int sweep_all, int priority);
uint64_t camo_wallet_prepared_fee(camo_wallet *w);
uint64_t camo_wallet_prepared_amount(camo_wallet *w);
const char *camo_wallet_commit(camo_wallet *w); /* returns txid(s), NULL on error */
void camo_wallet_discard(camo_wallet *w);

#ifdef __cplusplus
}
#endif
#endif
