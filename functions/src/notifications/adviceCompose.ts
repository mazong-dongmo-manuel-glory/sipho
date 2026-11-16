import { z } from "zod";
import {
  ADVICE_ROUTES,
  AdviceContext,
  AdviceFocus,
  AdviceLocale,
  adviceFacts,
  adviceViolations,
  buildAdvicePrompt,
  recommendedLessonFor,
  templateAdvice,
} from "../shared/advice";

/** Sends a prompt to a model and returns its raw JSON text, or null when it has nothing. */
export type AdviceAi = (prompt: string) => Promise<string | null>;

export interface ComposedAdvice {
  title: string;
  body: string;
  /** Where the notification opens in the app. */
  route: string;
  recommendedLessonId: string;
  /** `ai` when the model's wording passed every check, `template` otherwise. */
  source: "ai" | "template";
  /** Why the model's answer was refused, for the logs; empty otherwise. */
  rejected: string[];
}

const AiMessageSchema = z.object({
  title: z.string().trim().min(1),
  body: z.string().trim().min(1),
});

/**
 * Words the advice chosen by the rules. The model is asked first; its answer is only used when
 * it is valid JSON, short enough, free of forbidden topics and quotes no number that is not in
 * the facts. Otherwise (or when the model fails or is not configured) the template built from the
 * same facts is sent: the learner always gets a correct message.
 */
export async function composeAdvice(params: {
  ai: AdviceAi;
  focus: AdviceFocus;
  ctx: AdviceContext;
  locale: AdviceLocale;
  recentTitles: readonly string[];
}): Promise<ComposedAdvice> {
  const { ai, focus, ctx, locale, recentTitles } = params;
  const base = {
    route: ADVICE_ROUTES[focus],
    recommendedLessonId: recommendedLessonFor(focus, ctx),
  };
  const rejected: string[] = [];

  try {
    const raw = await ai(buildAdvicePrompt(focus, ctx, locale, recentTitles));
    if (raw) {
      const parsed = AiMessageSchema.safeParse(JSON.parse(raw));
      if (parsed.success) {
        const problems = adviceViolations(parsed.data, adviceFacts(focus, ctx));
        if (problems.length === 0) {
          return { ...parsed.data, ...base, source: "ai", rejected };
        }
        rejected.push(...problems);
      } else {
        rejected.push("bad-shape");
      }
    } else {
      rejected.push("no-answer");
    }
  } catch {
    rejected.push("ai-error");
  }

  return { ...templateAdvice(focus, ctx, locale), ...base, source: "template", rejected };
}
