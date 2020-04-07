/**
 * @license
 * Copyright 2016-2020 Balena Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { flags } from '@oclif/command';
import { stripIndent } from 'common-tags';
import Command from '../command';
import * as cf from '../utils/common-flags';
import { getBalenaSdk } from '../utils/lazy';

interface FlagsDef {
	application?: string;
	help?: void;
}

interface ArgsDef {
	deviceIpOrHostname?: string;
}

export default class JoinCmd extends Command {
	public static description = stripIndent`
		Promote a local device running balenaOS to join an application on a balena server.

		Move a local device to an application on another balena server.

		For example, you could provision a device against an openBalena installation
		where you perform end-to-end tests and then move it to balenaCloud when it's
		ready for production.

		To move a device between applications on the same server, use the
		\`balena device move\` command instead of \`balena join\`.

		If you don't specify a device hostname or IP, this command will automatically
		scan the local network for balenaOS devices and prompt you to select one
		from an interactive picker. This requires root privileges.  Likewise, if
		application flag is not provided then a picker will be shown.
	`;

	public static examples = [
		'$ balena join',
		'$ balena join balena.local',
		'$ balena join balena.local --application MyApp',
		'$ balena join 192.168.1.25',
		'$ balena join 192.168.1.25 --application MyApp',
	];

	public static args = [
		{
			name: 'deviceIpOrHostname',
			description: 'the IP or hostname of device',
		},
	];

	// Hardcoded to preserve camelcase
	public static usage = 'join [deviceIpOrHostname]';

	public static flags: flags.Input<FlagsDef> = {
		application: {
			description: 'the name of the application the device should join',
			...cf.application,
		},
		help: cf.help,
	};

	public static authenticated = true;
	public static primary = true;

	public async run() {
		const { args: params, flags: options } = this.parse<FlagsDef, ArgsDef>(
			JoinCmd,
		);

		const Logger = await import('../utils/logger');
		const promote = await import('../utils/promote');
		const sdk = getBalenaSdk();
		const logger = Logger.getLogger();
		return promote.join(
			logger,
			sdk,
			params.deviceIpOrHostname,
			options.application,
		);
	}
}
