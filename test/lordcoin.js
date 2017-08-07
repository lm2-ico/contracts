var LordCoin = artifacts.require("LordCoin.sol");

contract("LordCoin", function (accounts) {
    const _1ether = 1000000000000000000;

    it ("should put 20mln LCs on the first account", function () {
        return LordCoin.deployed().then(function (inst) {
            return inst.balanceOf.call(accounts[0]);
        }).then(function (balance) {
            assert.equal(balance.valueOf(), 20000000 * _1ether, "20mln LCs wasn't in the first account");
        });
    });

    it ("should send coins correctly", function () {
        var acc1 = accounts[0];
        var acc2 = accounts[1];

        var amount = 100;

        var lc;
        var acc1balance1;
        var acc2balance1;
        var acc1balance2;
        var acc2balance2;

        return LordCoin.deployed().then(function (inst) {
            lc = inst;
            return lc.balanceOf.call(acc1);
        }).then(function (balance) {
            acc1balance1 = balance.toNumber();
            return lc.balanceOf.call(acc2);
        }).then(function (balance) {
            acc2balance1 = balance.toNumber();
            return lc.transfer(acc2, amount, {from: acc1});
        }).then(function () {
            return lc.balanceOf.call(acc1);
        }).then(function (balance) {
            acc1balance2 = balance.toNumber();
            return lc.balanceOf.call(acc2);
        }).then(function (balance) {
            acc2balance2 = balance.toNumber();

            assert.equal(acc1balance2, acc1balance1 - amount, "Amount wasn't correctly taken from the sender");
            assert.equal(acc2balance2, acc2balance1 + amount, "Amount wasn't correctly sent to the receiver");
        })
    });

    it ("should burn coins correctly", function () {
        var acc1 = accounts[0];

        var amount = 10000000 * _1ether;

        var lc;
        var acc1balance1;
        var totalSupply1;
        var acc1balance2;
        var totalSupply2;

        return LordCoin.deployed().then(function (inst) {
            lc = inst;
            return lc.balanceOf.call(acc1);
        }).then(function (balance) {
            acc1balance1 = balance.toNumber();
            return lc.totalSupply.call();
        }).then(function (balance) {
            totalSupply1 = balance.toNumber();
            return lc.burn(amount, {from: acc1});
        }).then(function () {
            return lc.balanceOf.call(acc1);
        }).then(function (balance) {
            acc1balance2 = balance.toNumber();
            return lc.totalSupply.call();
        }).then(function (balance) {
            totalSupply2 = balance.toNumber();

            assert.equal(acc1balance2, acc1balance1 - amount, "Amount wasn't correctly burnt from the first account");
            assert.equal(totalSupply2, totalSupply1 - amount, "Amount wasn't correctly burnt from the totalSupply");
        })
    });
});