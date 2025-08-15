import * as logger from "firebase-functions/logger";
import * as functions from "firebase-functions";
import cors from "cors";
import axios from "axios";

const GEMINI_API_KEY = functions.config().gemini.key;

const GEMINI_API_URL =
  "https://generativelanguage.googleapis.com/v1beta/models/" +
  "gemini-1.5-flash:generateContent";

// CORSハンドラを作成（全てのオリジンを許可）
const corsHandler = cors({origin: true});

export const analyzeAnimeTrends = functions.https.onRequest(
  (req, res) => {
    corsHandler(req, res, async () => {
      try {
        const {animeList, username} = req.body;

        if (!Array.isArray(animeList) || animeList.length === 0) {
          res
            .status(400)
            .send("animeList is required and must be a non-empty array.");
          return;
        }
        if (!GEMINI_API_KEY) {
          res.status(500).send("GEMINI_API_KEY is not set.");
          return;
        }

        const titles = (animeList as Array<{ title: string }>)
          .map((a) => a.title)
          .filter((t: string) => !!t);

        const prompt = `
${username ? `${username}さん` : "このユーザー"}のアニメ視聴傾向を分析してください。
以下は最近視聴・選択したアニメタイトル一覧です。
${titles.map((t: string) => `- ${t}`).join("\n")}

傾向や好み、ジャンル、性格などを推測し、100文字程度でコメントしてください。
`;

        const response = await axios.post(
          `${GEMINI_API_URL}?key=${GEMINI_API_KEY}`,
          {
            contents: [
              {parts: [{text: prompt}]},
            ],
          },
          {
            headers: {
              "Content-Type": "application/json",
            },
          }
        );

        const resultText =
          response.data?.candidates?.[0]?.content?.parts?.[0]?.text ||
          "傾向分析コメントを生成できませんでした。";

        res.status(200).send({comment: resultText});
      } catch (error) {
        logger.error("Gemini API error", error);
        const errorMessage =
          error instanceof Error ?
            error.message :
            "Gemini API呼び出しに失敗しました。";
        res.status(500).send({error: errorMessage});
      }
    });
  }
);
