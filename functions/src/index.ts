/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as functions from "firebase-functions";
import axios from "axios";

// Gemini APIキーは環境変数で管理
const GEMINI_API_KEY = process.env.GEMINI_API_KEY;

// Gemini APIエンドポイント
const GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent";

// HTTPS関数: アニメ傾向分析
export const analyzeAnimeTrends = functions.https.onRequest(async (req, res) => {
  try {
    const { animeList, username } = req.body;

    if (!Array.isArray(animeList) || animeList.length === 0) {
      res.status(400).send("animeList is required and must be a non-empty array.");
      return;
    }
    if (!GEMINI_API_KEY) {
      res.status(500).send("GEMINI_API_KEY is not set.");
      return;
    }

    // プロンプト生成
    const titles = animeList.map((a: any) => a.title).filter((t: string) => !!t);
    const prompt = `
${username ? `${username}さん` : "このユーザー"}のアニメ視聴傾向を分析してください。
以下は最近視聴・選択したアニメタイトル一覧です。
${titles.map((t: string) => `- ${t}`).join('\n')}

傾向や好み、ジャンル、性格などを推測し、100文字程度でコメントしてください。
`;

    // Gemini APIリクエスト
    const response = await axios.post(
      `${GEMINI_API_URL}?key=${GEMINI_API_KEY}`,
      {
        contents: [
          { parts: [{ text: prompt }] }
        ]
      },
      {
        headers: {
          "Content-Type": "application/json"
        }
      }
    );

    const resultText =
      response.data?.candidates?.[0]?.content?.parts?.[0]?.text ||
      "傾向分析コメントを生成できませんでした。";

    res.status(200).send({ comment: resultText });
  } catch (error: any) {
    logger.error("Gemini API error", error);
    res.status(500).send({ error: error.message || "Gemini API呼び出しに失敗しました。" });
  }
});
