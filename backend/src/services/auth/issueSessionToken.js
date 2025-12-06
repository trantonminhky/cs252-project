import { randomUUID } from 'crypto';
import bcrypt from 'bcrypt';
import SessionTokensDB from '../../db/SessionTokensDB';

const SALT_ROUNDS = 10;

async function issueSessionToken(userID) {
	const tokenID = randomUUID();
	const rawSessionToken = randomUUID();
	const hashedSessionToken = await bcrypt.hash(rawSessionToken, SALT_ROUNDS);

	SessionTokensDB.set(tokenID, {
		userID: userID,
		hashedSessionToken: hashedSessionToken,
		createdAt: Date.now()
	});
	
	const bundled = `${tokenID}:${raw}`;
	return bundled;
}

export default {
	issueSessionToken
};