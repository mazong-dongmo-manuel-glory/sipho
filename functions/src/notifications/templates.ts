/**
 * Notification message templates — bilingual (FR/EN) with 10+ variants per type.
 */

export type NotifType =
  | "STREAK_REMINDER"
  | "BUDGET_WARNING"
  | "BUDGET_EXCEEDED"
  | "WEEKLY_INSIGHT"
  | "QUEST_EXPIRING"
  | "LEVEL_UP"
  | "STREAK_BROKEN";

export interface NotifTemplate {
  title: string;
  body: string;
}

type TemplateMap = Record<NotifType, NotifTemplate[]>;

export const TEMPLATES: Record<"fr" | "en", TemplateMap> = {
  fr: {
    STREAK_REMINDER: [
      { title: "🔥 Ta série t'attend !", body: "N'oublie pas ta leçon du jour pour garder ta flamme !" },
      { title: "⚡ Continue sur ta lancée !", body: "Une petite leçon et ta série continue. C'est parti ?" },
      { title: "📚 Moment finances !", body: "30 secondes suffisent pour garder ta série. Lance-toi !" },
      { title: "🌟 Chaque jour compte", body: "Maintiens ta série et monte en niveau plus vite !" },
      { title: "💡 Rappel Sipho", body: "Ta leçon quotidienne t'attend. Prêt(e) à apprendre ?" },
      { title: "🏆 Tu es si proche !", body: "Ne laisse pas ta série s'éteindre. Une leçon vite fait !" },
      { title: "🌱 Fais pousser tes graines", body: "Complète ta leçon pour gagner des graines aujourd'hui !" },
      { title: "🎯 Objectif du jour", body: "Complète une leçon et reste dans la course !" },
      { title: "⏰ Il est temps d'apprendre !", body: "Quelques minutes pour ta santé financière." },
      { title: "🚀 En avant !", body: "Une leçon par jour éloigne les dettes pour toujours." },
    ],
    BUDGET_WARNING: [
      { title: "⚠️ Budget presque atteint", body: "Tu as dépensé {pct}% de ton budget {category}. Fais attention !" },
      { title: "🔔 Alerte budget", body: "Ton budget {category} est utilisé à {pct}%. Ralentis un peu !" },
      { title: "💸 Attention aux dépenses", body: "{pct}% de ton budget {category} est parti. Il reste peu !" },
      { title: "📊 Point budget", body: "Tu approches la limite de {category}. Vérifie tes dépenses." },
      { title: "🧮 Plafond proche", body: "Encore {remaining} disponibles dans {category} ce mois-ci." },
    ],
    BUDGET_EXCEEDED: [
      { title: "🚨 Budget dépassé !", body: "Tu as dépassé ton budget {category} de {pct}%. Ajuste ton plan !" },
      { title: "❌ Plafond atteint", body: "Le budget {category} est épuisé pour ce mois. Pas de panique, analyse !" },
      { title: "💡 Dépasse mais apprends", body: "Budget {category} dépassé. C'est l'occasion de réviser ton plan !" },
    ],
    WEEKLY_INSIGHT: [
      { title: "📊 Ton bilan de la semaine", body: "Tes finances de cette semaine en un coup d'œil. Découvre tes insights !" },
      { title: "🧠 Sipho a analysé ta semaine", body: "Des conseils personnalisés t'attendent dans l'app !" },
      { title: "🌟 Rapport hebdomadaire", body: "Comment s'est passée ta semaine financière ? Clique pour le savoir." },
    ],
    QUEST_EXPIRING: [
      { title: "⏳ Quête qui expire bientôt !", body: "Ta quête \"{questName}\" expire dans {hours}h. Dépêche-toi !" },
      { title: "🎯 Dernière chance !", body: "Plus que {hours}h pour compléter \"{questName}\". Tu peux le faire !" },
    ],
    LEVEL_UP: [
      { title: "🎉 Niveau {level} atteint !", body: "Bravo ! Tu es maintenant niveau {level}. Continue comme ça !" },
      { title: "⬆️ Tu montes en niveau !", body: "Félicitations, tu es niveau {level} ! De nouvelles leçons t'attendent." },
      { title: "🏆 Nouveau palier !", body: "Niveau {level} débloqué ! Tu progresses à vitesse grand V." },
    ],
    STREAK_BROKEN: [
      { title: "💔 Ta série s'est arrêtée", body: "Ne te décourage pas ! Recommence dès aujourd'hui et reconstruis ta flamme." },
      { title: "😢 Série perdue...", body: "C'est reparti de zéro, mais tu peux le refaire ! Lance une leçon maintenant." },
      { title: "🔄 Nouveau départ !", body: "Ta série s'est interrompue. Pas grave — chaque jour est une nouvelle chance !" },
    ],
  },

  en: {
    STREAK_REMINDER: [
      { title: "🔥 Your streak is waiting!", body: "Don't forget today's lesson to keep your flame alive!" },
      { title: "⚡ Keep the momentum going!", body: "One quick lesson and your streak continues. Let's go?" },
      { title: "📚 Finance time!", body: "30 seconds is all it takes to keep your streak. Jump in!" },
      { title: "🌟 Every day counts", body: "Maintain your streak and level up faster!" },
      { title: "💡 Sipho reminder", body: "Your daily lesson is waiting. Ready to learn?" },
      { title: "🏆 You're so close!", body: "Don't let your streak die. Quick lesson time!" },
      { title: "🌱 Grow your seeds", body: "Complete your lesson to earn seeds today!" },
      { title: "🎯 Daily goal", body: "Complete a lesson and stay in the race!" },
      { title: "⏰ Time to learn!", body: "A few minutes for your financial health." },
      { title: "🚀 Let's go!", body: "A lesson a day keeps the debts away." },
    ],
    BUDGET_WARNING: [
      { title: "⚠️ Budget almost reached", body: "You've spent {pct}% of your {category} budget. Watch out!" },
      { title: "🔔 Budget alert", body: "Your {category} budget is {pct}% used. Slow down a bit!" },
      { title: "💸 Watch your spending", body: "{pct}% of your {category} budget is gone. Not much left!" },
      { title: "📊 Budget check", body: "You're approaching your {category} limit. Review your spending." },
      { title: "🧮 Limit approaching", body: "{remaining} remaining in {category} this month." },
    ],
    BUDGET_EXCEEDED: [
      { title: "🚨 Budget exceeded!", body: "You've exceeded your {category} budget by {pct}%. Time to adjust!" },
      { title: "❌ Limit reached", body: "Your {category} budget is depleted for the month. Time to analyze!" },
      { title: "💡 Exceeded but learning", body: "{category} budget exceeded. Great time to review your plan!" },
    ],
    WEEKLY_INSIGHT: [
      { title: "📊 Your weekly recap", body: "Your finances this week at a glance. Check your insights!" },
      { title: "🧠 Sipho analyzed your week", body: "Personalized advice is waiting for you in the app!" },
      { title: "🌟 Weekly report", body: "How was your financial week? Tap to find out." },
    ],
    QUEST_EXPIRING: [
      { title: "⏳ Quest expiring soon!", body: 'Your quest "{questName}" expires in {hours}h. Hurry!' },
      { title: "🎯 Last chance!", body: '{hours}h left to complete "{questName}". You can do it!' },
    ],
    LEVEL_UP: [
      { title: "🎉 Level {level} reached!", body: "Congrats! You're now level {level}. Keep it up!" },
      { title: "⬆️ Level up!", body: "You're level {level}! New lessons are waiting for you." },
      { title: "🏆 New milestone!", body: "Level {level} unlocked! You're progressing fast." },
    ],
    STREAK_BROKEN: [
      { title: "💔 Your streak ended", body: "Don't give up! Start again today and rebuild your flame." },
      { title: "😢 Streak lost...", body: "Back to zero, but you can do it again! Start a lesson now." },
      { title: "🔄 Fresh start!", body: "Your streak broke. No worries — every day is a new chance!" },
    ],
  },
};

/**
 * Pick a random template variant for a given type and locale.
 */
export function pickTemplate(
  type: NotifType,
  locale: "fr" | "en",
  vars: Record<string, string> = {}
): NotifTemplate {
  const pool = TEMPLATES[locale][type];
  const tpl = pool[Math.floor(Math.random() * pool.length)];
  const interpolate = (s: string): string =>
    s.replace(/\{(\w+)\}/g, (_match: string, k: string) => vars[k] ?? `{${k}}`);
  return { title: interpolate(tpl.title), body: interpolate(tpl.body) };
}
