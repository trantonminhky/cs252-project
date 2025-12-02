// this was made by AI. don't expect much
function unwrapTyped(x) {
	if (Array.isArray(x)) return x.map(unwrapTyped);

	if (x && typeof x === "object") {
		const keys = Object.keys(x);

		// Typed wrapper: has "t" always, may or may not have "v"
		if (keys.includes("t")) {
			if (keys.includes("v")) {
				// Normal typed value: recurse into v
				return unwrapTyped(x.v);
			}
			// Typed with no v -> treat as null
			return null;
		}

		const out = {};
		for (const k of keys) out[k] = unwrapTyped(x[k]);
		return out;
	}

	return x;
}

export default unwrapTyped;