const LordCoinICOMock = artifacts.require("./LordCoinICOMock.sol");
const LordCoin = artifacts.require("./LordCoin.sol");

const gasPrice = 100000000000;
const _1ether = 1000000000000000000;
const _1hour = 60 * 60;

const period5hours = 2;
const period5hours2 = 4;
const period5Days = 48;
const periodLastWeek = 24 + 24 * 7 * 4;

contract('LordCoinICO', function(accounts) {
	it('should give +20% for the first 5 hours', async () => {
		await testTokensPerPeriod(accounts, 3300, period5hours);
	});
	it('should give +12% for the first 5 days', async () => {
		await testTokensPerPeriod(accounts, 3000, period5Days);
	});
	it('should give no discount the last week', async () => {
		await testTokensPerPeriod(accounts, 2640, periodLastWeek);
	});
	it('should give correct statistics during sale', async () => {
		const acc0 = accounts[0];
		const acc1 = accounts[1];

		const acc2 = accounts[3];
		const acc3 = accounts[4];
		const acc4 = accounts[5];

		const startDate = 1510012800;

		const {token, sale} = await initContracts(acc1, startDate);

		await token.transfer(sale.address, 13000000 * _1ether, {from: acc0});

		let tokens = 3300;
		let totalEther = 1;
		await testStatistics(sale, token, acc2, tokens, 1, totalEther, startDate + _1hour * period5hours, 1);

		tokens += 4 * 3300;
		totalEther += 4;
		await testStatistics(sale, token, acc3, tokens, 4, totalEther, startDate + _1hour * period5hours2, 2);

		tokens += 3 * 3000;
		totalEther += 3;
		await testStatistics(sale, token, acc3, tokens, 3, totalEther, startDate + _1hour * period5Days, 2);

		tokens += 40 * 2640;
		totalEther += 40;
		await testStatistics(sale, token, acc4, tokens, 40, totalEther, startDate + _1hour * periodLastWeek, 3);

	});
	it('should transfer all the LorCoins to beneficiary after sale is finished', async () => {
		const acc0 = accounts[0];
		const acc1 = accounts[1];
		const acc2 = accounts[6];

		const startDate = 1510012800;

		const {token, sale} = await initContracts(acc1, startDate);

		await token.transfer(sale.address, 13000000 * _1ether, {from: acc0});

		await sale.changeTime(startDate + _1hour * period5Days);

		const ether = 50;
		await sale.sendTransaction({from: acc2, value: _1ether * ether});

		await sale.finishCrowdsale();

		const lcLeft = (await token.balanceOf.call(acc1)).toNumber();
		const saleLCs = (await token.balanceOf.call(sale.address)).toNumber();

		assert.equal(lcLeft, (13000000 - 3000 * ether) * _1ether, "LordCoins left must be equal initial size minus LordCoins sold");
		assert.equal(saleLCs, 0, "No LordCoins must be on the contract");

		await expectThrow(sale.sendTransaction({from: acc2, value: _1ether}), "Forbidden to send ether after the crowdsale");
	});
});

async function initContracts (beneficiary, startDate) {
	const token = await LordCoin.new();
	const sale = await LordCoinICOMock.new(token.address, beneficiary, 1, 3300, startDate, 5, 5 * 24, 30);

	return {token, sale};
};

async function testTokensPerPeriod(accounts, tokens, period) {
		const acc0 = accounts[0];
		const acc1 = accounts[1];
		const acc2 = accounts[2];

		const startDate = 1510012800;

		const {token, sale} = await initContracts(acc1, startDate);

		await token.transfer(sale.address, 13000000 * _1ether, {from: acc0});

		await sale.changeTime(startDate + _1hour * period);

		await sale.sendTransaction({from: acc2, value: _1ether});

		const weiAmount = await sale.weiRaised.call();
		const tokenAmount = await token.balanceOf.call(acc2);
		const investors = await sale.investorCount.call();

		assert.equal(weiAmount.toNumber(), _1ether, "Wei amount not equal to payed amount");
		assert.equal(tokenAmount.toNumber(), tokens * _1ether, "Token amount not equal to " + tokens);
		assert.equal(investors.toNumber(), 1, "Investors number must be 1");
};

async function testStatistics(sale, lc, acc, tokens, ether, totalEther, time, investorsCount) {
		await sale.changeTime(time);
		await sale.sendTransaction({from: acc, value: _1ether * ether});

		const weiRaised = (await sale.weiRaised.call()).toNumber();
		const tokensSold = (await sale.lcSold.call()).toNumber();
		const investors = (await sale.investorCount.call()).toNumber();
		const tokensLeft = (await lc.balanceOf(sale.address)).toNumber();

		assert.equal(weiRaised, totalEther * _1ether, "weiRaised not equal to payed amount");
		assert.equal(tokensSold, tokens * _1ether, "lcSold not equal to sold amount");
		assert.equal(investors, investorsCount, "investorCount must be " + investorsCount);

};

async function expectThrow(promise, comment) {
	try {
		await promise;
	} catch (error) {
		return;
	}

	assert.fail(comment);
}