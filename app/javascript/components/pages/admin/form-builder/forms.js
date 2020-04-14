import { fromJS } from "immutable";
import { object, string, boolean } from "yup";

import { RECORD_TYPES } from "../../../../config/constants";
import {
  FieldRecord,
  FormSectionRecord,
  TEXT_FIELD,
  SELECT_FIELD,
  TICK_FIELD,
  LABEL_FIELD
} from "../../../form";

export const validationSchema = object().shape({
  description: object().shape({
    en: string().required()
  }),
  form_group_id: string().required(),
  module: string().required(),
  name: object().shape({
    en: string().required()
  }),
  record_type: string().required(),
  visible: boolean()
});

export const settingsForm = i18n =>
  fromJS([
    FormSectionRecord({
      unique_id: "settings",
      name: i18n.t("forms.settings"),
      fields: [
        FieldRecord({
          display_name: i18n.t("forms.title"),
          name: "name.en",
          type: TEXT_FIELD,
          required: true,
          help_text: i18n.t("forms.help_text.must_be_english")
        }),
        FieldRecord({
          display_name: i18n.t("forms.description"),
          name: "description.en",
          type: TEXT_FIELD,
          required: true,
          help_text: i18n.t("forms.help_text.summariaze_purpose")
        }),
        FieldRecord({
          display_name: i18n.t("forms.form_group"),
          name: "form_group_id",
          type: SELECT_FIELD,
          required: true,
          help_text: i18n.t("forms.help_text.related_groups"),
          option_strings_source: "FormGroup",
          freeSolo: true
        }),
        [
          FieldRecord({
            display_name: i18n.t("forms.record_type"),
            name: "record_type",
            type: SELECT_FIELD,
            option_strings_text: Object.values(RECORD_TYPES).reduce(
              (results, item) => {
                if (item !== RECORD_TYPES.all) {
                  results.push({
                    id: item,
                    display_text: i18n.t(`forms.record_types.${item}`)
                  });
                }

                return results;
              },
              []
            ),
            required: true
          }),
          FieldRecord({
            display_name: i18n.t("forms.module"),
            name: "module",
            type: SELECT_FIELD,
            option_strings_source: "Module",
            required: true
          })
        ]
      ]
    }),
    FormSectionRecord({
      unique_id: "visibility",
      name: i18n.t("forms.visibility"),
      fields: [
        FieldRecord({
          display_name: i18n.t("forms.show_on"),
          name: "show_on",
          type: LABEL_FIELD
        }),
        [
          FieldRecord({
            display_name: i18n.t("forms.web_app"),
            name: "visible",
            type: TICK_FIELD
          })
        ]
      ]
    })
  ]);
