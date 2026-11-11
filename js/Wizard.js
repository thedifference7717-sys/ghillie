.pragma library

function switchPage(next) {
    // Android focus workaround
    releaseFocus();

    // save settings for current page;
    if (next && typeof pages[currentPage].onPageClosed !== 'undefined') {
        if (pages[currentPage].onPageClosed(settings) !== true) {
            print ("Can't go to the next page");
            return;
        };

    }
    console.log("switchpage: currentPage: ", currentPage);

    // Update prev/next button positions for mobile/desktop
    prevButton.anchors.verticalCenter = wizard.verticalCenter
    nextButton.anchors.verticalCenter = wizard.verticalCenter

    if (currentPage > 0 || currentPage < pages.length - 1) {
        pages[currentPage].opacity = 0
        var step_value = next ? 1 : -1
        currentPage += step_value
        pages[currentPage].opacity = 1;

        var nextButtonVisible = currentPage > 1 && currentPage < pages.length - 1
        nextButton.visible = nextButtonVisible

        if (typeof pages[currentPage].onPageOpened !== 'undefined') {
            pages[currentPage].onPageOpened(settings,next)
        }
    }
}

function createWalletPath(isIOS, folder_path,account_name){
    // Store releative path on ios.
    if(isIOS)
        folder_path = "";

    return folder_path + "/" + account_name + "/" + account_name
}

function walletPathExists(accountsDir, directory, filename, isIOS, walletManager) {
    if(!filename || filename === "") return false;
    if(!directory || directory === "") return false;

    if (!directory.endsWith("/") && !directory.endsWith("\\"))
        directory += "/"

    if(isIOS)
        var path = accountsDir + filename;
    else
        var path = directory + filename + "/" + filename;

    if (walletManager.walletExists(path))
        return true;
    return false;
}

function unusedWalletName(directory, filename, walletManager) {
    for (var i = 0; i < 100; i++) {
        var walletName = filename + (i > 0 ? "_" + i : "");
        if (!walletManager.walletExists(directory + "/" + walletName + "/" + walletName)) {
            return walletName;
        }
    }

    return filename;
}

function isAscii(str){
    for (var i = 0; i < str.length; i++) {
        if (str.charCodeAt(i) > 127)
            return false;
    }
    return true;
}

function tr(text) {
    return qsTr(text) + translationManager.emptyString
}

function usefulName(path) {
    // arbitrary "short enough" limit
    if (path.length < 32)
        return path
    return path.replace(/.*[\/\\]/, '').replace(/\.keys$/, '')
}

function checkSeed(seed) {
    console.log("Checking seed")
    var wordsArray = seed.split(/\s+/);
    return wordsArray.length === 25 || wordsArray.length === 24
}

function restoreWalletCheckViewSpendAddress(walletmanager, nettype, viewkey, spendkey, addressline){
    var results = [];
    // addressOK
    results[0] = walletmanager.addressValid(addressline, nettype);
    // viewKeyOK
    results[1] = walletmanager.keyValid(viewkey, addressline, true, nettype);
    // spendKeyOK, Spendkey is optional
    results[2] = walletmanager.keyValid(spendkey, addressline, false, nettype);
    return results;
}

//usage: getApproximateBlockchainHeight("March 18 2016") or getApproximateBlockchainHeight("2016-11-11")
//returns estimated block height with 1 month buffer prior to requested date.
function getApproximateBlockchainHeight(_date, _nettype){
    // CAMO: one chain era, 60-second blocks from block 1 (DIFFICULTY_TARGET_V2 = 60).
    // Chain start times: mainnet launch 2026-12-15 18:00 UTC; public stagenet started 2026-11-11 20:05 UTC.
    // Testnet has no public chain yet, so it always restores from 0.
    var chainStartTime = _nettype == "Mainnet" ? 1797357600 : _nettype == "Stagenet" ? 1794427500 : 0;
    var secondsPerBlock = 60;
    var requestedTime = Math.floor(new Date(_date) / 1000);
    if (chainStartTime === 0 || requestedTime <= chainStartTime) {
        console.log("Calculated blockchain height: 0");
        return 0;
    }
    var approxBlockchainHeight = Math.floor((requestedTime - chainStartTime) / secondsPerBlock);
    console.log("Calculated blockchain height: " + approxBlockchainHeight);
    // start a month early to be safe: scanning extra blocks is harmless, missing them is not
    var blocksPerMonth = 60*60*24*30/secondsPerBlock;
    return Math.max(0, approxBlockchainHeight - blocksPerMonth);
}
