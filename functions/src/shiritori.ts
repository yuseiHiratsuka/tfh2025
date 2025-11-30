export type ShiritoriValidationResult = {
    isValid: boolean;
    reasonCode: string | null;
    reason: string | null;
};

/**
 * カタカナをひらがなに変換する
 * @param str 変換する文字列
 * @return ひらがなに変換された文字列
 */
function katakanaToHiragana(str: string): string {
    return str.replace(/[\u30a1-\u30f6]/g, (match) => {
        const chr = match.charCodeAt(0) - 0x60;
        return String.fromCharCode(chr);
    });
}

/**
 * しりとり判定ヘルパー関数
 * @param currentChar 現在の文字
 * @param firstChar 提出された単語の最初の文字
 * @param lastChar 提出された単語の最後の文字
 * @param usedWords 使用済み単語のリスト
 * @param word 提出された単語
 * @param chainCount 現在のチェーン数
 * @param goalCharacter ゴール文字
 * @return {isValid: boolean, reasonCode: string | null, reason: string | null}
 */
export function validateShiritori(
    currentChar: string,
    firstChar: string,
    lastChar: string,
    usedWords: string[],
    word: string,
    chainCount: number,
    goalCharacter: string
): ShiritoriValidationResult {
    // カタカナをひらがなに正規化
    const normalizedCurrentChar = katakanaToHiragana(currentChar);
    const normalizedFirstChar = katakanaToHiragana(firstChar);
    const normalizedLastChar = katakanaToHiragana(lastChar);
    const normalizedGoalCharacter = katakanaToHiragana(goalCharacter);

    // しりとりチェック: 現在の文字と一致するか
    if (normalizedCurrentChar !== normalizedFirstChar) {
        return {
            isValid: false,
            reasonCode: "start_char_mismatch",
            reason: `「${currentChar}」から始まる絵を描いてください（「${firstChar}」から始まっています）`,
        };
    }

    // 重複チェック: すでに使用された単語でないか
    if (usedWords.includes(word)) {
        return {
            isValid: false,
            reasonCode: "word_duplicated",
            reason: "この単語はすでに使用されています。",
        };
    }

    // 「ん」禁止ルール（ゴール文字が「ん」の場合を除く）
    if (normalizedLastChar === "ん" && normalizedGoalCharacter !== "ん") {
        return {
            isValid: false,
            reasonCode: "ends_with_n",
            reason: "「ん」で終わる言葉は使えません",
        };
    }

    // 最低ターン数ルール（3ターン未満でゴール到達不可）
    if (chainCount < 2 && normalizedLastChar === normalizedGoalCharacter) {
        return {
            isValid: false,
            reasonCode: "min_turns_not_reached",
            reason: `最低3ターン必要です（現在${chainCount + 1}ターン目）`,
        };
    }

    return { isValid: true, reasonCode: null, reason: null };
}

/**
 * AIターン判定関数
 * @param chainCount 現在のチェーン数
 * @returns AI投稿が必要かどうか
 */
export function shouldAISubmit(chainCount: number): boolean {
    // ターン3 (chainCount = 2 の次)
    if (chainCount === 2) return true;

    // ターン5 (chainCount = 4 の次)
    if (chainCount === 4) return true;

    // ターン11以降、3回に1回 (chainCount = 10, 13, 16, 19...)
    if (chainCount >= 10 && (chainCount - 10) % 3 === 0) {
        return true;
    }

    return false;
}
