/**
 * Sandbox runner for JavaScript user code.
 *
 * Receives JSON on stdin:
 * {
 *     "code": "function twoSum(nums, target) { ... }",
 *     "test_cases": [
 *         {"input": "[2,7,11,15], 9", "expected_output": "[0,1]"},
 *         ...
 *     ],
 *     "function_name": "twoSum"
 * }
 *
 * Outputs JSON on stdout.
 */

const { stdin, stdout } = require('process');

function normalizeOutput(val) {
    if (val === null || val === undefined) return "null";
    if (typeof val === "boolean") return val ? "true" : "false";
    if (Array.isArray(val)) return JSON.stringify(val);
    if (typeof val === "object") return JSON.stringify(val);
    return String(val);
}

function parseExpected(expected) {
    expected = expected.trim();
    try {
        const parsed = JSON.parse(expected);
        return normalizeOutput(parsed);
    } catch {
        return expected;
    }
}

function main(payload) {
    const { code, test_cases, function_name = "solution" } = payload;
    const results = [];
    let overallStatus = "accepted";
    let errorMsg = null;

    // Execute user code in current scope
    let userFunc;
    try {
        // Create a function that defines user code and returns the target function
        const wrappedCode = `${code}\nreturn typeof ${function_name} === 'function' ? ${function_name} : undefined;`;
        userFunc = new Function(wrappedCode)();
        if (!userFunc) {
            throw new Error(`Function '${function_name}' not found in submitted code`);
        }
    } catch (e) {
        errorMsg = `${e.name}: ${e.message}`;
        overallStatus = "runtime_error";
        for (const tc of test_cases) {
            results.push({
                input: tc.input,
                expected: tc.expected_output,
                actual: null,
                passed: false,
            });
        }
        stdout.write(JSON.stringify({ status: overallStatus, test_results: results, error: errorMsg }));
        return;
    }

    // Run each test case
    for (const tc of test_cases) {
        const testInput = tc.input;
        const expected = parseExpected(tc.expected_output);

        try {
            // Parse input args: "arg1, arg2" -> [arg1, arg2]
            const args = new Function(`return [${testInput}]`)();
            const result = userFunc(...args);
            const actual = normalizeOutput(result);
            const passed = actual === expected;

            if (!passed) overallStatus = "wrong_answer";

            results.push({
                input: testInput,
                expected: expected,
                actual: actual,
                passed: passed,
            });
        } catch (e) {
            overallStatus = "runtime_error";
            errorMsg = `${e.name}: ${e.message}`;
            results.push({
                input: testInput,
                expected: expected,
                actual: null,
                passed: false,
            });
        }
    }

    stdout.write(JSON.stringify({ status: overallStatus, test_results: results, error: errorMsg }));
}

// Read stdin
let data = '';
stdin.setEncoding('utf8');
stdin.on('data', chunk => { data += chunk; });
stdin.on('end', () => {
    try {
        main(JSON.parse(data));
    } catch (e) {
        stdout.write(JSON.stringify({
            status: "runtime_error",
            test_results: [],
            error: `Runner error: ${e.message}`,
        }));
    }
});
