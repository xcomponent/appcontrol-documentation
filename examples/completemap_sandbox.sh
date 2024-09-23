<?xml version="1.0" encoding="utf-8" standalone="yes" ?>
<apps>
	<hosts>
		<host hostid="LOCAL" host="localhost" port="12567" sslprotocol="Tls12" />
	</hosts>
	<auths>
		<auth authid="LOCAL" domain="" password="" user="" />
	</auths>
	<app name="completemap" version="v1">
		<component name="A1" description="A1 component" group="A group" hostref="LOCAL" authref="LOCAL" redirectoutput="false" type="file">
			<action value="sandbox.sh check app-A-component-0" name="check" />
			<action value="sandbox.sh enable app-A-component-0" name="enable" />
			<action value="sandbox.sh disable app-A-component-0" name="disable" />
			<action value="echo $(message)" commandname="echo Action" name="custom">
				<parameters>
					<parameter name="message" value="Welcome message" canedit="true" validation="*" />
				</parameters>
			</action>
		</component>
		<component name="A1.1" description="A1.1 component" group="A group" hostref="LOCAL" authref="LOCAL" redirectoutput="true" type="browser">
			<father>A1</father>
			<action value="sandbox.sh check app-A-component-1.1" name="check" />
			<action value="sandbox.sh enable app-A-component-1.1" name="enable" />
			<action value="sandbox.sh disable app-A-component-1.1" name="disable" />
		</component>
		<component name="A1.1.1" description="A1.1.1 component" group="A group" hostref="LOCAL" authref="LOCAL" redirectoutput="false" type="browser">
			<father>A1.1</father>
			<action value="sandbox.sh check app-A-component-1.1.1" name="check" />
			<action value="sandbox.sh enable app-A-component-1.1.1" name="enable" />
			<action value="sandbox.sh disable app-A-component-1.1.1" name="disable" />
		</component>
		<component name="A1.1.2" description="A1.1.2 component" group="A group" hostref="LOCAL" authref="LOCAL" redirectoutput="false" type="cd">
			<father>A1.1</father>
			<action value="sandbox.sh check app-A-component-1.1.2" name="check" />
			<action value="sandbox.sh enable app-A-component-1.1.2" name="enable" />
			<action value="sandbox.sh disable app-A-component-1.1.2" name="disable" />
		</component>
		<component name="A1.1.3" description="A1.1.3 component" group="A group" hostref="LOCAL" authref="LOCAL" redirectoutput="false" type="chip">
			<father>A1.1</father>
			<action value="sandbox.sh check app-A-component-1.1.3" name="check" />
			<action value="sandbox.sh enable app-A-component-1.1.3" name="enable" />
			<action value="sandbox.sh disable app-A-component-1.1.3" name="disable" />
		</component>
		<component name="A1.2" description="A1.2 component" group="A group" hostref="LOCAL" authref="LOCAL" redirectoutput="false" type="cd">
			<father>A1</father>
			<action value="sandbox.sh check app-A-component-1.2" name="check" />
			<action value="sandbox.sh enable app-A-component-1.2" name="enable" />
			<action value="sandbox.sh disable app-A-component-1.2" name="disable" />
		</component>
		<component name="A1.2.1" description="A1.2.1 component" group="A group" hostref="LOCAL" authref="LOCAL" redirectoutput="false" type="browser">
			<father>A1.2</father>
			<action value="sandbox.sh check app-A-component-1.2.1" name="check" />
			<action value="sandbox.sh enable app-A-component-1.2.1" name="enable" />
			<action value="sandbox.sh disable app-A-component-1.2.1" name="disable" />
		</component>
		<component name="A1.2.2" description="A1.2.2 component" group="A group" hostref="LOCAL" authref="LOCAL" redirectoutput="false" type="cd">
			<father>A1.2</father>
			<action value="sandbox.sh check app-A-component-1.2.2" name="check" />
			<action value="sandbox.sh enable app-A-component-1.2.2" name="enable" />
			<action value="sandbox.sh disable app-A-component-1.2.2" name="disable" />
		</component>
		<component name="A1.2.3" description="A1.2.3 component" group="A group" hostref="LOCAL" authref="LOCAL" redirectoutput="false" type="chip">
			<father>A1.2</father>
			<action value="sandbox.sh check app-A-component-1.2.3" name="check" />
			<action value="sandbox.sh enable app-A-component-1.2.3" name="enable" />
			<action value="sandbox.sh disable app-A-component-1.2.3" name="disable" />
		</component>
		<component name="A1.3" description="A1.3 component" group="A2 group" hostref="LOCAL" authref="LOCAL" redirectoutput="false" type="chip">
			<father>A1</father>
			<action value="sandbox.sh check app-A-component-1.3" name="check" />
			<action value="sandbox.sh enable app-A-component-1.3" name="enable" />
			<action value="sandbox.sh disable app-A-component-1.3" name="disable" />
		</component>
		<component name="A1.3.1" description="A1.3.1 component" group="A2 group" hostref="LOCAL" authref="LOCAL" redirectoutput="false" type="browser">
			<father>A1.3</father>
			<action value="sandbox.sh check app-A-component-1.3.1" name="check" />
			<action value="sandbox.sh enable app-A-component-1.3.1" name="enable" />
			<action value="sandbox.sh disable app-A-component-1.3.1" name="disable" />
		</component>
		<component name="A1.3.2" description="A1.3.2 component" group="A2 group" hostref="LOCAL" authref="LOCAL" redirectoutput="false" type="cd">
			<father>A1.3</father>
			<action value="sandbox.sh check app-A-component-1.3.2" name="check" />
			<action value="sandbox.sh enable app-A-component-1.3.2" name="enable" />
			<action value="sandbox.sh disable app-A-component-1.3.2" name="disable" />
		</component>
		<component name="A1.3.3" description="A1.3.3 component" group="A2 group" hostref="LOCAL" authref="LOCAL" redirectoutput="false" type="chip">
			<father>A1.3</father>
			<action value="sandbox.sh check app-A-component-1.3.3" name="check" />
			<action value="sandbox.sh enable app-A-component-1.3.3" name="enable" />
			<action value="sandbox.sh disable app-A-component-1.3.3" name="disable" />
		</component>
	</app>
</apps>
