#
# Copyright (C) 2026 Nethesis S.r.l.
# SPDX-License-Identifier: GPL-3.0-or-later
#

"""Synapse module that keeps the rooms of local users unencrypted.

Loaded only when encryption_disabled is set. Clients like Element X and Cinny
ignore the io.element.e2ee well-known policy, so the server enforces it.
"""

ENCRYPTION_EVENT = "m.room.encryption"


class EncryptionPolicy:
    def __init__(self, config, api):
        self._api = api
        api.register_third_party_rules_callbacks(
            on_create_room=self.on_create_room,
            check_event_allowed=self.check_event_allowed,
        )

    @staticmethod
    def parse_config(config):
        return config

    async def on_create_room(self, requester, config, is_requester_admin):
        # Dropping the event creates the room in clear text, refusing it would fail the client
        initial_state = config.get("initial_state")
        if isinstance(initial_state, list):
            config["initial_state"] = [
                state for state in initial_state
                if not (isinstance(state, dict) and state.get("type") == ENCRYPTION_EVENT)
            ]

    async def check_event_allowed(self, event, state_events):
        # Rooms of other servers follow their own rules
        if event.type == ENCRYPTION_EVENT and event.is_state() and self._api.is_mine(event.sender):
            return False, None
        return True, None
