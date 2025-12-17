export type ShiritoriValidationResult = {
    isValid: boolean;
    reasonCode: string | null;
    reason: string | null;
};

const SMALL_KANA = new Set([
    "ぁ", "ぃ", "ぅ", "ぇ", "ぉ",
    "ゃ", "ゅ", "ょ", "ゎ",
    "ァ", "ィ", "ゥ", "ェ", "ォ",
    "ャ", "ュ", "ョ", "ヮ",
    "っ", "ッ",
    "ゕ", "ゖ", "ヵ", "ヶ",
]);

const SMALL_TO_LARGE: Record<string, string> = {
    "ぁ": "あ", "ぃ": "い", "ぅ": "う", "ぇ": "え", "ぉ": "お",
    "ゃ": "や", "ゅ": "ゆ", "ょ": "よ", "ゎ": "わ",
    "ァ": "ア", "ィ": "イ", "ゥ": "ウ", "ェ": "エ", "ォ": "オ",
    "ャ": "ヤ", "ュ": "ユ", "ョ": "ヨ", "ヮ": "ワ",
    "っ": "つ", "ッ": "ツ",
    "ゕ": "か", "ゖ": "け", "ヵ": "カ", "ヶ": "ケ",
};

const CHOONPU = "ー";

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
 * しりとりの先頭に使う文字列を抽出する
 * 先頭+次の文字が小文字の場合はセットで返す
 */
export function getShiritoriHead(word: string): string {
    const chars = Array.from(word);
    if (chars.length === 0) return "";

    const [first, second] = chars;
    if (second && SMALL_KANA.has(second)) {
        return first + second;
    }

    return first;
}

/**
 * しりとりの末尾に使う文字列を抽出する
 * - 長音符は無視し、直前の文字を末尾として扱う
 * - 小文字で終わる場合は直前の文字とセットで返す
 * - 単独の小文字で終わる場合は大文字化して返す
 */
export function getShiritoriTail(word: string): string {
    const chars = Array.from(word);
    if (chars.length === 0) return "";

    while (chars.length > 0 && chars[chars.length - 1] === CHOONPU) {
        chars.pop();
    }

    if (chars.length === 0) return "";

    const last = chars.pop()!;

    if (SMALL_KANA.has(last)) {
        if (chars.length > 0) {
            return chars[chars.length - 1] + last;
        }
        return SMALL_TO_LARGE[last] || last;
    }

    return last;
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
