import { getShiritoriHead, getShiritoriTail, validateShiritori } from "../shiritori";

describe("getShiritoriHead", () => {
    it("2文字目が小文字ならセットで返す", () => {
        expect(getShiritoriHead("キャラメル")).toBe("キャ");
    });

    it("通常の文字なら1文字だけ返す", () => {
        expect(getShiritoriHead("ねこ")).toBe("ね");
    });
});

describe("getShiritoriTail", () => {
    it("長音は無視して直前の文字を返す", () => {
        expect(getShiritoriTail("コーヒー")).toBe("ヒ");
    });

    it("小文字で終わる場合は直前の文字とセットで返す", () => {
        expect(getShiritoriTail("スパゲッティー")).toBe("ティ");
    });

    it("単独の小文字で終わる場合は大文字化して返す", () => {
        expect(getShiritoriTail("ぁ")).toBe("あ");
    });
});

describe("validateShiritori", () => {
    describe("ひらがなとカタカナの区別なし", () => {
        it("ひらがなの現在文字とカタカナの最初の文字が一致する場合、validになる", () => {
            const result = validateShiritori(
                "あ", // currentChar (ひらがな)
                "ア", // firstChar (カタカナ)
                "い", // lastChar
                [], // usedWords
                "アイス", // word
                1, // chainCount
                "ん" // goalCharacter
            );
            expect(result.isValid).toBe(true);
        });

        it("カタカナの現在文字とひらがなの最初の文字が一致する場合、validになる", () => {
            const result = validateShiritori(
                "ア", // currentChar (カタカナ)
                "あ", // firstChar (ひらがな)
                "い", // lastChar
                [], // usedWords
                "あいす", // word
                1, // chainCount
                "ん" // goalCharacter
            );
            expect(result.isValid).toBe(true);
        });

        it("カタカナの「ン」で終わる場合も禁止される", () => {
            const result = validateShiritori(
                "あ", // currentChar
                "あ", // firstChar
                "ン", // lastChar (カタカナ)
                [], // usedWords
                "あめりかン", // word
                1, // chainCount
                "き" // goalCharacter
            );
            expect(result.isValid).toBe(false);
            expect(result.reasonCode).toBe("ends_with_n");
        });

        it("ゴール文字がカタカナで最後の文字がひらがなでも一致判定される", () => {
            const result = validateShiritori(
                "あ", // currentChar
                "あ", // firstChar
                "ん", // lastChar (ひらがな)
                [], // usedWords
                "あめりかん", // word
                2, // chainCount
                "ン" // goalCharacter (カタカナ)
            );
            expect(result.isValid).toBe(true);
        });

        it("ゴール文字がひらがなで最後の文字がカタカナでも一致判定される", () => {
            const result = validateShiritori(
                "あ", // currentChar
                "あ", // firstChar
                "ン", // lastChar (カタカナ)
                [], // usedWords
                "あめりかン", // word
                2, // chainCount
                "ん" // goalCharacter (ひらがな)
            );
            expect(result.isValid).toBe(true);
        });
    });

    describe("しりとりの基本ルール", () => {
        it("現在の文字と最初の文字が一致しない場合、invalidになる", () => {
            const result = validateShiritori(
                "あ", // currentChar
                "い", // firstChar
                "す", // lastChar
                [], // usedWords
                "いす", // word
                1, // chainCount
                "ん" // goalCharacter
            );
            expect(result.isValid).toBe(false);
            expect(result.reasonCode).toBe("start_char_mismatch");
        });

        it("すでに使用された単語の場合、invalidになる", () => {
            const result = validateShiritori(
                "あ", // currentChar
                "あ", // firstChar
                "い", // lastChar
                ["あい"], // usedWords
                "あい", // word
                1, // chainCount
                "ん" // goalCharacter
            );
            expect(result.isValid).toBe(false);
            expect(result.reasonCode).toBe("word_duplicated");
        });

        it("「ん」で終わる場合、invalidになる（ゴールが「ん」でない場合）", () => {
            const result = validateShiritori(
                "あ", // currentChar
                "あ", // firstChar
                "ん", // lastChar
                [], // usedWords
                "あめりかん", // word
                1, // chainCount
                "き" // goalCharacter
            );
            expect(result.isValid).toBe(false);
            expect(result.reasonCode).toBe("ends_with_n");
        });

        it("3ターン未満でゴールに到達した場合、invalidになる", () => {
            const result = validateShiritori(
                "あ", // currentChar
                "あ", // firstChar
                "ん", // lastChar
                [], // usedWords
                "あめりかん", // word
                1, // chainCount (2ターン目)
                "ん" // goalCharacter
            );
            expect(result.isValid).toBe(false);
            expect(result.reasonCode).toBe("min_turns_not_reached");
        });

        it("3ターン以上でゴールに到達した場合、validになる", () => {
            const result = validateShiritori(
                "あ", // currentChar
                "あ", // firstChar
                "ん", // lastChar
                [], // usedWords
                "あめりかん", // word
                2, // chainCount (3ターン目)
                "ん" // goalCharacter
            );
            expect(result.isValid).toBe(true);
        });
    });
});
