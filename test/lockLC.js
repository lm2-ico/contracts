const LordCoinLockMock = artifacts.require("./LordCoinLockMock.sol");
const LordCoin = artifacts.require("./LordCoin.sol");

const gasPrice = 100000000000;
const _1ether = 1000000000000000000;
const _1hour = 60 * 60;

contract('LordCoinLock', function(accounts) {
	it('should not allow withdraw LC before the first date', async () => {

		const startDate = 1510012800;

		const {token, lock} = await initContracts(startDate);

		await lock.changeTime(startDate + _1hour * 24);

		await expectThrow(lock.withdraw1(10), "It must be forbidden to withdraw1");
		await expectThrow(lock.withdraw2(10), "It must be forbidden to withdraw2");
	});

	it('should allow withdraw half of LCs after the first date and before the second date', async () => {
		const acc0 = accounts[0];

		const startDate = 1510012800;

		const {token, lock} = await initContracts(startDate);

		await lock.changeTime(startDate + _1hour * 24 * 185);

		await expectThrow(lock.withdraw1(2000000 * _1ether), "It must be forbidden to withdraw1 more than a 1 000 000 LCs");
		
		await lock.withdraw1(500000 * _1ether);

		await expectThrow(lock.withdraw2(10), "It must be forbidden to withdraw2");
	});

	it('should allow withdraw LCs after the second date', async () => {
		const acc0 = accounts[0];

		const startDate = 1510012800;

		const {token, lock} = await initContracts(startDate);

		await lock.changeTime(startDate + _1hour * 24 * 370);

		await expectThrow(lock.withdraw1(2000000 * _1ether), "It must be forbidden to withdraw1 more than a 1 000 000 LCs");
		
		await lock.withdraw1(500000 * _1ether);

		await lock.withdraw2(500000 * _1ether);
	});

	it('should withdraw allowed amount of LCs after the first date', async () => {
		const acc0 = accounts[0];

		const startDate = 1510012800;

		const {token, lock} = await initContracts(startDate);

		await lock.changeTime(startDate + _1hour * 24 * 185);

		const amount = 500000 * _1ether;
		
		await expectThrow(lock.withdraw1(2000000 * _1ether), "It must be forbidden to withdraw1 more than a 1 000 000 LCs");		
		
		await lock.withdraw1(amount);
		await lock.withdraw1(amount);
		await expectThrow(lock.withdraw1(1), "No LCs must be left for tranche 1");
	});

	it('should allowed to withdraw one half after the first date and the second half after the second date', async () => {
		const acc0 = accounts[0];

		const startDate = 1510012800;

		const {token, lock} = await initContracts(startDate);


		const amount = 1000000 * _1ether;
		
		await lock.changeTime(startDate + _1hour * 24 * 185);
		await expectThrow(lock.withdraw1(2000000 * _1ether), "It must be forbidden to withdraw1 more than a 1 000 000 LCs");				
		await lock.withdraw1(amount);

		await lock.changeTime(startDate + _1hour * 24 * 700);
		await lock.withdraw2(amount);
		
		await expectThrow(lock.withdraw1(1), "No LCs must be left for tranche 1");
	});
});

async function initContracts (startDate) {
	const token = await LordCoin.new();
	const lock = await LordCoinLockMock.new(token.address, startDate, 183, 1000000 * _1ether);

	await token.transfer(lock.address, 2000000 * _1ether);

	return {token, lock};
};

async function expectThrow (promise, comment) {
	try {
		await promise;
	} catch (error) {
		return;
	}

	assert.fail(comment);
}