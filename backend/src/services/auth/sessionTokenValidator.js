import { randomUUID } from 'crypto';
import bcrypt from 'bcrypt';
import SessionTokensDB from '../../db/SessionTokensDB';

const SALT_ROUNDS = 10;
const SESSION_TOKEN_LIFETIME = 604800000;

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

async function validateSessionToken(bundled) {
	if (!bundled) return null;

	const [tokenID, rawSessionToken] = bundled.split(':');
	if (!tokenID || !raw) return null;

	const sessionToken = SessionTokensDB.get(tokenID);
	if (!entry) return null;

	if (Date.now() - SESSION_TOKEN_LIFETIME > sessionToken.createdAt) {
		SessionTokensDB.delete(tokenID);
		return null;
	}

	const sessionTokenMatch = await bcrypt.compare(rawSessionToken, sessionToken.hashedSessionToken);
	if (!sessionTokenMatch) return null;

	const data = {
		userID: sessionToken.userID,
		tokenID: tokenID
	};
	return data;
}

export default {
	issueSessionToken,
	validateSessionToken
};