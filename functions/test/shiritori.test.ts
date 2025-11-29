import { shouldAISubmit, validateShiritori } from "../src/shiritori";

type ValidateParams = {
    currentChar: string;
    firstChar: string;
    lastChar: string;
    usedWords: string[];
    word: string;
    chainCount: number;
    goalCharacter: string;
};

const runValidate = (params: Partial<ValidateParams> = {}) => {
    const defaults: ValidateParams = {
        currentChar: "あ",
        firstChar: "あ",
        lastChar: "い",
        usedWords: [],
        word: "あい",
        chainCount: 2,
        goalCharacter: "か",
    };

    const merged = { ...defaults, ...params };

    return validateShiritori(
        merged.currentChar,
        merged.firstChar,
        merged.lastChar,
        merged.usedWords,
        merged.word,
        merged.chainCount,
        merged.goalCharacter
    );
};

describe("validateShiritori", () => {
    it("開始文字が一致しない場合は無効", () => {
        const result = runValidate({ currentChar: "か", firstChar: "き" });

        expect(result).toEqual({
            isValid: false,
            reasonCode: "start_char_mismatch",
            reason: "「か」から始まる絵を描いてください（「き」から始まっています）",
        });
    });

    it("使用済み単語は無効", () => {
        const result = runValidate({ usedWords: ["あい", "いか"], word: "あい" });

        expect(result).toEqual({
            isValid: false,
            reasonCode: "word_duplicated",
            reason: "この単語はすでに使用されています。",
        });
    });

    it("最後が「ん」で終わるとゴールが「ん」以外なら無効", () => {
        const result = runValidate({ lastChar: "ん", word: "あん" });

        expect(result).toEqual({
            isValid: false,
            reasonCode: "ends_with_n",
            reason: "「ん」で終わる言葉は使えません",
        });
    });

    it("ゴール文字が「ん」の場合は「ん」終わりでも許容", () => {
        const result = runValidate({
            lastChar: "ん",
            word: "あん",
            goalCharacter: "ん",
            chainCount: 5,
        });

        expect(result).toEqual({
            isValid: true,
            reasonCode: null,
            reason: null,
        });
    });

    it("最低ターン未達でゴール文字に到達した場合は無効", () => {
        const result = runValidate({
            lastChar: "か",
            goalCharacter: "か",
            chainCount: 1,
            word: "あか",
        });

        expect(result).toEqual({
            isValid: false,
            reasonCode: "min_turns_not_reached",
            reason: "最低3ターン必要です（現在2ターン目）",
        });
    });

    it("全ての条件を満たす場合は有効", () => {
        const result = runValidate({
            currentChar: "そ",
            firstChar: "そ",
            lastChar: "ら",
            word: "そら",
            usedWords: ["あい"],
            chainCount: 3,
            goalCharacter: "ん",
        });

        expect(result).toEqual({
            isValid: true,
            reasonCode: null,
            reason: null,
        });
    });
});

describe("shouldAISubmit", () => {
    const cases: Array<{ chainCount: number; expected: boolean }> = [
        { chainCount: 0, expected: false },
        { chainCount: 1, expected: false },
        { chainCount: 2, expected: true },
        { chainCount: 3, expected: false },
        { chainCount: 4, expected: true },
        { chainCount: 5, expected: false },
        { chainCount: 10, expected: true },
        { chainCount: 11, expected: false },
        { chainCount: 13, expected: true },
        { chainCount: 16, expected: true },
    ];

    it.each(cases)("chainCount=%s のとき %s を返す", ({ chainCount, expected }) => {
        expect(shouldAISubmit(chainCount)).toBe(expected);
    });
});
