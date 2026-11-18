<!--
  Copyright (C) 2023 Nethesis S.r.l.
  SPDX-License-Identifier: GPL-3.0-or-later
-->
<template>
  <cv-grid fullWidth>
    <cv-row>
      <cv-column class="page-title">
        <h2>{{ $t("settings.title") }}</h2>
      </cv-column>
    </cv-row>
    <cv-row v-if="error.getConfiguration">
      <cv-column>
        <NsInlineNotification
          kind="error"
          :title="$t('action.get-configuration')"
          :description="error.getConfiguration"
          :showCloseButton="false"
        />
      </cv-column>
    </cv-row>
    <cv-row>
      <cv-column>
        <cv-tile light>
          <cv-form @submit.prevent="configureModule">
            <cv-text-input
              :label="$t('settings.synapse_domain_name')"
              v-model="synapse_domain_name"
              :placeholder="$t('settings.synapse_domain_placeholder')"
              :disabled="loading.getConfiguration || loading.configureModule"
              :invalid-message="error.synapse_domain_name"
              ref="synapse_domain_name"
            ></cv-text-input>
            <cv-text-input
              :label="$t('settings.element_domain_name')"
              v-model="element_domain_name"
              :placeholder="$t('settings.element_domain_placeholder')"
              :disabled="loading.getConfiguration || loading.configureModule"
              :invalid-message="error.element_domain_name"
              ref="element_domain_name"
            ></cv-text-input>
            <cv-text-input
              :label="$t('settings.cinny_domain_name')"
              v-model="cinny_domain_name"
              :placeholder="$t('settings.cinny_domain_placeholder')"
              :disabled="loading.getConfiguration || loading.configureModule"
              :invalid-message="error.cinny_domain_name"
              ref="cinny_domain_name"
            ></cv-text-input>
            <NsComboBox
              v-model.trim="ldap_domain"
              :autoFilter="true"
              :autoHighlight="true"
              :title="$t('settings.ldap_domain')"
              :label="$t('settings.choose_ldap_domain')"
              :options="domains_list"
              :acceptUserInput="false"
              :showItemType="true"
              :invalid-message="$t(error.ldap_domain)"
              :disabled="loading.getConfiguration || loading.configureModule"
              tooltipAlignment="start"
              tooltipDirection="top"
              ref="ldap_domain"
            >
              <template slot="tooltip">
                {{ $t("settings.choose_the_ldap_domain_to_use") }}
              </template>
            </NsComboBox>
            <NsToggle
              value="letsEncrypt"
              :label="core.$t('apps_lets_encrypt.request_https_certificate')"
              v-model="isLetsEncryptEnabled"
              :disabled="loading.getConfiguration || loading.configureModule"
              class="mg-bottom"
            >
              <template #tooltip>
                <div class="mg-bottom-sm">
                  {{ core.$t("apps_lets_encrypt.lets_encrypt_tips") }}
                </div>
                <div class="mg-bottom-sm">
                  <cv-link @click="goToCertificates">
                    {{ core.$t("apps_lets_encrypt.go_to_tls_certificates") }}
                  </cv-link>
                </div>
              </template>
              <template slot="text-left">{{
                $t("settings.disabled")
              }}</template>
              <template slot="text-right">{{
                $t("settings.enabled")
              }}</template>
            </NsToggle>
            <cv-accordion ref="accordion" class="mg-bottom">
              <cv-accordion-item :open="isAdvancedOpen">
                <template slot="title">{{ $t("settings.advanced") }}</template>
                <template slot="content">
                  <cv-text-input
                    :label="$t('settings.mail_from')"
                    v-model="mail_from"
                    :placeholder="$t('settings.mail_from_placeholder')"
                    :disabled="
                      loading.getConfiguration || loading.configureModule
                    "
                    :invalid-message="error.mail_from"
                    ref="mail_from"
                  ></cv-text-input>
                  <cv-text-input
                    :label="$t('settings.nethvoice_auth_url')"
                    v-model="nethvoice_auth_url"
                    :placeholder="$t('settings.nethvoice_auth_url_placeholder')"
                    :disabled="
                      loading.getConfiguration || loading.configureModule
                    "
                    :invalid-message="error.nethvoice_auth_url"
                    ref="nethvoice_auth_url"
                  >
                    <template slot="tooltip">
                      {{
                        $t("settings.nethvoice_auth_url_placeholder_tooltip")
                      }}
                    </template>
                  </cv-text-input>
                  <NsToggle
                    value="federation"
                    :label="$t('settings.federation')"
                    v-model="federation"
                    :disabled="
                      loading.getConfiguration || loading.configureModule
                    "
                    class="mg-bottom"
                    ref="federation"
                  >
                    <template #tooltip>
                      {{ $t("settings.federation_tooltip") }}
                    </template>
                    <template slot="text-left">{{
                      $t("settings.disabled")
                    }}</template>
                    <template slot="text-right">{{
                      $t("settings.enabled")
                    }}</template>
                  </NsToggle>
                  <template v-if="federation || error.federation_whitelist">
                    <NsInlineNotification
                      v-if="!isLetsEncryptEnabled"
                      kind="warning"
                      :title="$t('settings.federation_certificate_title')"
                      :description="
                        $t('settings.federation_certificate_description')
                      "
                      :showCloseButton="false"
                    />
                    <cv-text-area
                      :label="$t('settings.federation_whitelist')"
                      v-model.trim="federation_whitelist"
                      :helper-text="$t('settings.federation_whitelist_helper')"
                      :placeholder="
                        $t('settings.federation_whitelist_placeholder')
                      "
                      :invalid-message="error.federation_whitelist"
                      :disabled="
                        loading.getConfiguration || loading.configureModule
                      "
                      class="mg-bottom"
                      ref="federation_whitelist"
                    ></cv-text-area>
                  </template>
                  <NsToggle
                    value="search_all_users"
                    :label="$t('settings.search_all_users')"
                    v-model="search_all_users"
                    :disabled="
                      loading.getConfiguration || loading.configureModule
                    "
                    class="mg-bottom"
                    ref="search_all_users"
                  >
                    <template #tooltip>
                      {{ $t("settings.search_all_users_tooltip") }}
                    </template>
                    <template slot="text-left">{{
                      $t("settings.disabled")
                    }}</template>
                    <template slot="text-right">{{
                      $t("settings.enabled")
                    }}</template>
                  </NsToggle>
                  <cv-text-area
                    :label="$t('settings.turn_uris')"
                    v-model.trim="turn_uris"
                    :helper-text="$t('settings.turn_uris_helper')"
                    :placeholder="$t('settings.turn_uris_placeholder')"
                    :invalid-message="error.turn_uris"
                    :disabled="
                      loading.getConfiguration || loading.configureModule
                    "
                    class="mg-bottom"
                    ref="turn_uris"
                  ></cv-text-area>
                  <NsTextInput
                    v-if="turn_uris || error.turn_shared_secret"
                    type="password"
                    :label="$t('settings.turn_shared_secret')"
                    v-model="turn_shared_secret"
                    :placeholder="
                      turn_shared_secret_set
                        ? $t('settings.turn_shared_secret_unchanged')
                        : ''
                    "
                    :helper-text="$t('settings.turn_shared_secret_helper')"
                    :invalid-message="error.turn_shared_secret"
                    :disabled="
                      loading.getConfiguration || loading.configureModule
                    "
                    autocomplete="new-password"
                    ref="turn_shared_secret"
                  />
                  <div v-if="turn_shared_secret_set" class="mg-bottom">
                    <NsInlineNotification
                      v-if="turn_clear_secret"
                      kind="warning"
                      :title="$t('settings.turn_secret_will_be_removed')"
                      :showCloseButton="false"
                    />
                    <NsButton
                      kind="ghost"
                      size="field"
                      :icon="turn_clear_secret ? Undo16 : TrashCan16"
                      :disabled="
                        loading.getConfiguration || loading.configureModule
                      "
                      @click="turn_clear_secret = !turn_clear_secret"
                    >
                      {{
                        turn_clear_secret
                          ? $t("settings.keep_stored_turn_secret")
                          : $t("settings.remove_stored_turn_secret")
                      }}
                    </NsButton>
                  </div>
                  <NsTextInput
                    type="number"
                    min="1"
                    max="2048"
                    :label="$t('settings.max_upload_size_mb')"
                    v-model.number="max_upload_size_mb"
                    :invalid-message="error.max_upload_size_mb"
                    :disabled="
                      loading.getConfiguration || loading.configureModule
                    "
                    ref="max_upload_size_mb"
                  />
                  <NsTextInput
                    type="number"
                    min="0"
                    :label="$t('settings.local_media_lifetime_days')"
                    v-model.number="local_media_lifetime_days"
                    :helper-text="$t('settings.media_lifetime_helper')"
                    :invalid-message="error.local_media_lifetime_days"
                    :disabled="
                      loading.getConfiguration || loading.configureModule
                    "
                    ref="local_media_lifetime_days"
                  />
                  <NsTextInput
                    v-if="federation"
                    type="number"
                    min="0"
                    :label="$t('settings.remote_media_lifetime_days')"
                    v-model.number="remote_media_lifetime_days"
                    :helper-text="$t('settings.media_lifetime_helper')"
                    :invalid-message="error.remote_media_lifetime_days"
                    :disabled="
                      loading.getConfiguration || loading.configureModule
                    "
                    ref="remote_media_lifetime_days"
                  />
                  <NsComboBox
                    v-model="log_level"
                    :label="$t('settings.log_level')"
                    :title="$t('settings.log_level')"
                    :options="logLevelOptions"
                    :invalid-message="error.log_level"
                    :disabled="
                      loading.getConfiguration || loading.configureModule
                    "
                    ref="log_level"
                  />
                </template>
              </cv-accordion-item>
            </cv-accordion>
            <cv-row v-if="error.configureModule">
              <cv-column>
                <NsInlineNotification
                  kind="error"
                  :title="$t('action.configure-module')"
                  :description="error.configureModule"
                  :showCloseButton="false"
                />
              </cv-column>
            </cv-row>
            <NsButton
              kind="primary"
              :icon="Save20"
              :loading="loading.configureModule"
              :disabled="loading.getConfiguration || loading.configureModule"
              >{{ $t("settings.save") }}
            </NsButton>
          </cv-form>
        </cv-tile>
      </cv-column>
    </cv-row>
  </cv-grid>
</template>

<script>
import to from "await-to-js";
import { mapState } from "vuex";
import {
  QueryParamService,
  UtilService,
  TaskService,
  IconService,
  PageTitleService,
} from "@nethserver/ns8-ui-lib";
import TrashCan16 from "@carbon/icons-vue/es/trash-can/16";
import Undo16 from "@carbon/icons-vue/es/undo/16";

export default {
  name: "Settings",
  mixins: [
    TaskService,
    IconService,
    UtilService,
    QueryParamService,
    PageTitleService,
  ],
  pageTitle() {
    return this.$t("settings.title") + " - " + this.appName;
  },
  data() {
    return {
      q: {
        page: "settings",
      },
      urlCheckInterval: null,
      synapse_domain_name: "",
      element_domain_name: "",
      cinny_domain_name: "",
      domains_list: [],
      ldap_domain: "",
      mail_from: "",
      nethvoice_auth_url: "",
      isLetsEncryptEnabled: false,
      federation: false,
      federation_whitelist: "",
      turn_uris: "",
      turn_shared_secret: "",
      turn_shared_secret_set: false,
      turn_clear_secret: false,
      TrashCan16,
      Undo16,
      max_upload_size_mb: 50,
      local_media_lifetime_days: 0,
      remote_media_lifetime_days: 0,
      search_all_users: false,
      log_level: "INFO",
      isAdvancedOpen: false,
      advancedFields: [
        "mail_from",
        "nethvoice_auth_url",
        "federation_whitelist",
        "turn_uris",
        "turn_shared_secret",
        "max_upload_size_mb",
        "local_media_lifetime_days",
        "remote_media_lifetime_days",
        "log_level",
      ],
      logLevelOptions: [
        { name: "INFO", label: "INFO", value: "INFO" },
        { name: "WARNING", label: "WARNING", value: "WARNING" },
        { name: "DEBUG", label: "DEBUG", value: "DEBUG" },
      ],
      loading: {
        getConfiguration: false,
        configureModule: false,
      },
      error: {
        getConfiguration: "",
        configureModule: "",
        synapse_domain_name: "",
        element_domain_name: "",
        cinny_domain_name: "",
        ldap_domain: "",
        mail_from: "",
        nethvoice_auth_url: "",
        lets_encrypt: "",
        federation_whitelist: "",
        turn_uris: "",
        turn_shared_secret: "",
        max_upload_size_mb: "",
        local_media_lifetime_days: "",
        remote_media_lifetime_days: "",
        log_level: "",
      },
    };
  },
  computed: {
    ...mapState(["instanceName", "core", "appName"]),
  },
  beforeRouteEnter(to, from, next) {
    next((vm) => {
      vm.watchQueryData(vm);
      vm.urlCheckInterval = vm.initUrlBindingForApp(vm, vm.q.page);
    });
  },
  beforeRouteLeave(to, from, next) {
    clearInterval(this.urlCheckInterval);
    next();
  },
  created() {
    this.getConfiguration();
  },
  methods: {
    splitLines(text) {
      return text
        .split(/[\s,]+/)
        .map((item) => item.trim())
        .filter((item) => item);
    },
    goToCertificates() {
      this.core.$router.push("/settings/tls-certificates");
    },
    async getConfiguration() {
      this.loading.getConfiguration = true;
      this.error.getConfiguration = "";
      const taskAction = "get-configuration";
      const eventId = this.getUuid();

      // register to task error
      this.core.$root.$once(
        `${taskAction}-aborted-${eventId}`,
        this.getConfigurationAborted
      );

      // register to task completion
      this.core.$root.$once(
        `${taskAction}-completed-${eventId}`,
        this.getConfigurationCompleted
      );

      const res = await to(
        this.createModuleTaskForApp(this.instanceName, {
          action: taskAction,
          extra: {
            title: this.$t("action." + taskAction),
            isNotificationHidden: true,
            eventId,
          },
        })
      );
      const err = res[0];

      if (err) {
        console.error(`error creating task ${taskAction}`, err);
        this.error.getConfiguration = this.getErrorMessage(err);
        this.loading.getConfiguration = false;
        return;
      }
    },
    getConfigurationAborted(taskResult, taskContext) {
      console.error(`${taskContext.action} aborted`, taskResult);
      this.error.getConfiguration = this.$t("error.generic_error");
      this.loading.getConfiguration = false;
    },
    getConfigurationCompleted(taskContext, taskResult) {
      this.loading.getConfiguration = false;
      const config = taskResult.output;

      // Set configuration fields
      this.synapse_domain_name = config.synapse_domain_name || "";
      this.element_domain_name = config.element_domain_name || "";
      this.cinny_domain_name = config.cinny_domain_name || "";
      this.domains_list = config.domains_list;
      this.mail_from = config.mail_from || "";
      this.nethvoice_auth_url = config.nethvoice_auth_url || "";
      this.isLetsEncryptEnabled = config.lets_encrypt;
      this.federation = config.federation || false;
      this.federation_whitelist = (config.federation_whitelist || []).join(
        "\n"
      );
      this.turn_uris = (config.turn_uris || []).join("\n");
      this.turn_shared_secret = "";
      this.turn_shared_secret_set = config.turn_shared_secret_set || false;
      this.turn_clear_secret = false;
      this.max_upload_size_mb = config.max_upload_size_mb || 50;
      this.local_media_lifetime_days = config.local_media_lifetime_days || 0;
      this.remote_media_lifetime_days = config.remote_media_lifetime_days || 0;
      this.search_all_users = config.search_all_users || false;
      // open the advanced section when it holds non default values
      this.isAdvancedOpen =
        this.mail_from !== "" ||
        this.nethvoice_auth_url !== "" ||
        this.federation ||
        this.turn_uris !== "" ||
        this.max_upload_size_mb !== 50 ||
        this.local_media_lifetime_days !== 0 ||
        this.remote_media_lifetime_days !== 0 ||
        (config.log_level || "INFO") !== "INFO";

      // force to reload value after dom update
      this.$nextTick(() => {
        this.ldap_domain = config.ldap_domain;
        this.log_level = config.log_level || "INFO";
      });

      // Focus first configuration field
      this.focusElement("synapse_domain_name");
    },
    validateConfigureModule() {
      this.clearErrors(this);
      let isValidationOk = true;

      // Validate synapse domain name
      if (!this.synapse_domain_name) {
        this.error.synapse_domain_name = this.$t("common.required");
        if (isValidationOk) {
          this.focusElement("synapse_domain_name");
          isValidationOk = false;
        }
      }

      // Validate ldap domain
      if (!this.ldap_domain) {
        this.error.ldap_domain = this.$t("common.required");

        if (isValidationOk) {
          this.focusElement("ldap_domain");
          isValidationOk = false;
        }
      }

      // an emptied number input gives "", which means the default value
      const numberFields = [
        { name: "max_upload_size_mb", min: 1, max: 2048, empty: 50 },
        { name: "local_media_lifetime_days", min: 0, empty: 0 },
        { name: "remote_media_lifetime_days", min: 0, empty: 0 },
      ];
      for (const field of numberFields) {
        if (this[field.name] === "") {
          this[field.name] = field.empty;
        }
        const value = this[field.name];
        const isValid =
          Number.isInteger(value) &&
          value >= field.min &&
          (field.max === undefined || value <= field.max);

        if (!isValid) {
          this.error[field.name] =
            field.max === undefined
              ? this.$t("settings.number_min", { min: field.min })
              : this.$t("settings.number_range", {
                  min: field.min,
                  max: field.max,
                });

          if (isValidationOk) {
            this.isAdvancedOpen = true;
            this.focusElement(field.name);
            isValidationOk = false;
          }
        }
      }
      return isValidationOk;
    },
    configureModuleValidationFailed(validationErrors) {
      this.loading.configureModule = false;
      let focusAlreadySet = false;

      for (const validationError of validationErrors) {
        // array items are reported as "turn_uris.0", the error belongs to the whole list
        const field = validationError.field.split(".")[0];
        if (this.advancedFields.includes(field)) {
          this.isAdvancedOpen = true;
        }

        if (field !== "(root)") {
          // set i18n error message
          this.error[field] = validationError.field.includes(".")
            ? this.$t("settings.invalid_list_item", {
                value: validationError.value,
              })
            : this.$t("settings." + validationError.error);

          // focus after the accordion opened, and only if the field is rendered
          if (!focusAlreadySet) {
            focusAlreadySet = true;
            this.$nextTick(() => {
              if (this.$refs[field]) {
                this.focusElement(field);
              }
            });
          }
        }
      }
    },
    async configureModule() {
      const isValidationOk = this.validateConfigureModule();
      if (!isValidationOk) {
        return;
      }

      this.loading.configureModule = true;
      const taskAction = "configure-module";
      const eventId = this.getUuid();

      // register to task error
      this.core.$root.$once(
        `${taskAction}-aborted-${eventId}`,
        this.configureModuleAborted
      );

      // register to task validation
      this.core.$root.$once(
        `${taskAction}-validation-failed-${eventId}`,
        this.configureModuleValidationFailed
      );

      // register to task completion
      this.core.$root.$once(
        `${taskAction}-completed-${eventId}`,
        this.configureModuleCompleted
      );

      const res = await to(
        this.createModuleTaskForApp(this.instanceName, {
          action: taskAction,
          data: {
            synapse_domain_name: this.synapse_domain_name,
            element_domain_name: this.element_domain_name,
            cinny_domain_name: this.cinny_domain_name,
            ldap_domain: this.ldap_domain,
            mail_from: this.mail_from,
            nethvoice_auth_url: this.nethvoice_auth_url,
            lets_encrypt: this.isLetsEncryptEnabled,
            federation: this.federation,
            // sent even when federation is off, so the list is kept for later
            federation_whitelist: this.splitLines(this.federation_whitelist),
            turn_uris: this.splitLines(this.turn_uris),
            turn_shared_secret: this.turn_shared_secret,
            turn_clear_secret: this.turn_clear_secret,
            max_upload_size_mb: this.max_upload_size_mb,
            local_media_lifetime_days: this.local_media_lifetime_days,
            remote_media_lifetime_days: this.remote_media_lifetime_days,
            log_level: this.log_level,
            search_all_users: this.search_all_users,
          },
          extra: {
            title: this.$t("settings.configure_instance", {
              instance: this.instanceName,
            }),
            description: this.$t("common.processing"),
            eventId,
          },
        })
      );
      const err = res[0];

      if (err) {
        console.error(`error creating task ${taskAction}`, err);
        this.error.configureModule = this.getErrorMessage(err);
        this.loading.configureModule = false;
        return;
      }
    },
    configureModuleAborted(taskResult, taskContext) {
      console.error(`${taskContext.action} aborted`, taskResult);
      this.error.configureModule = this.$t("error.generic_error");
      this.loading.configureModule = false;
    },
    configureModuleCompleted() {
      this.loading.configureModule = false;

      // reload configuration
      this.getConfiguration();
    },
  },
};
</script>

<style scoped lang="scss">
@import "../styles/carbon-utils";
</style>
