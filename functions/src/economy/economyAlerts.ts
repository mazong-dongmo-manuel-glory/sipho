import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { logger } from "../shared/logger";

interface EconomyIndicator {
  value?: number;
  date?: string;
  source?: string;
}

interface EconomyDoc {
  indicators?: {
    keyRate?: EconomyIndicator;
  };
}

export const economyAlerts = onDocumentUpdated(
  {
    document: "economy/{countryCode}",
    region: "us-central1",
  },
  (event) => {
    const countryCode = event.params.countryCode;
    const before = event.data?.before.data() as EconomyDoc | undefined;
    const after = event.data?.after.data() as EconomyDoc | undefined;

    const beforeRate = before?.indicators?.keyRate?.value;
    const afterRate = after?.indicators?.keyRate?.value;
    const source = after?.indicators?.keyRate?.source;
    const date = after?.indicators?.keyRate?.date;

    if (
      typeof beforeRate === "number" &&
      typeof afterRate === "number" &&
      beforeRate !== afterRate &&
      typeof source === "string" &&
      typeof date === "string"
    ) {
      logger.info("detected dated central bank rate change", {
        countryCode,
        beforeRate,
        afterRate,
        source,
        date,
      });
    }
  }
);
