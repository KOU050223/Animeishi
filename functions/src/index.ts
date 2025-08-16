import * as functions from "firebase-functions";
import * as logger from "firebase-functions/logger";
import axios from "axios";
// eslint-disable-next-line max-len
import type {Request as ExpressRequest, Response as ExpressResponse} from "express-serve-static-core";

const GEMINI_API_KEY = process.env.GEMINI_KEY || "";
const GEMINI_API_URL =
  "https://generativelanguage.googleapis.com/v1beta/models/" +
  "gemini-1.5-flash:generateContent";

export default functions.https.onRequest(
  async (req: ExpressRequest, res: ExpressResponse) => {
    // CORS ヘッダを設定
    res.set("Access-Control-Allow-Origin", "*");
    res.set("Access-Control-Allow-Headers", "*");
    res.set("Access-Control-Allow-Methods", "GET, HEAD, OPTIONS, POST");

    // プリフライト OPTIONS リクエストは即座に終了
    if (req.method === "OPTIONS") {
      res.status(204).end();
      return;
    }

    try {
      const {animeList, username} = req.body as {
        animeList: Array<{ title: string }>;
        username?: string;
      };

      if (!Array.isArray(animeList) || animeList.length === 0) {
        res.status(400).send("non-empty array.");
        return;
      }

      if (!GEMINI_API_KEY) {
        res.status(500).send("GEMINI_API_KEY is not set.");
        return;
      }

      const titles = animeList.map((a) => a.title).filter((t) => !!t);

      const prompt = `
${username ? `${username}さん` : "このユーザー"}のアニメ視聴傾向を分析してください。
以下は最近視聴・選択したアニメタイトル一覧です。
${titles.map((t) => `- ${t}`).join("\n")}

傾向や好み、ジャンル、性格などを推測し、
100文字程度でコメントしてください。
`;

      const response = await axios.post(
        `${GEMINI_API_URL}?key=${GEMINI_API_KEY}`,
        {contents: [{parts: [{text: prompt}]}]},
        {headers: {"Content-Type": "application/json"}}
      );

      const resultText =
        response.data?.candidates?.[0]?.content?.parts?.[0]?.text ??
        "傾向分析コメントを生成できませんでした。";

      res.status(200).send({comment: resultText});
    } catch (error) {
      logger.error("Gemini API error", error);
      const errorMessage = error instanceof Error ?
        error.message :
        "Gemini API呼び出しに失敗しました。";
      res.status(500).send({error: errorMessage});
    }
  }
);
