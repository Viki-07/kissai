import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:kissai/provider/sshprovider.dart';
import 'package:provider/provider.dart';

Future openBalloon(
    String name,
    String title,
    String time,
    int height,
    String description,
    String sources,
    String appname,
    // String imagename,
    SSHClientProvider sshClientProvider) async {
  print('ran');
  int rigs = 3;
  rigs = (sshClientProvider.rigs / 2).floor() + 1;
  String openBalloonKML = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Document>
	<name>$name.kml</name>
	<Style id="purple_paddle">
		<IconStyle>
			<Icon>
				<href>https://raw.githubusercontent.com/yashrajbharti/kml-images/main/molten.png</href>
			</Icon>
		</IconStyle>
		<BalloonStyle>
			<text>\$[description]</text>
      <bgColor>ff1e1e1e</bgColor>
		</BalloonStyle>
	</Style>
	<Placemark id="0A7ACC68BF23CB81B354">
		<name>$title</name>
		<Snippet maxLines="0"></Snippet>
		<description><![CDATA[<!-- BalloonStyle background color:
ffffffff
 -->
<!-- Icon URL:
http://maps.google.com/mapfiles/kml/paddle/purple-blank.png
 -->
<table width="400" border="0" cellspacing="0" cellpadding="5">
  <tr>
    <td colspan="2" align="center">
      <img src="https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjzI4JzY6oUy-dQaiW-HLmn5NQ7qiw7NUOoK-2cDU9cI6JwhPrNv0EkCacuKWFViEgXYrCFzlbCtHZQffY6a73j6_ATFjfeU7r6OxXxN5K8sGjfOlp3vvd6eCXZrozlu34fUG5_cKHmzZWa4axb-vJRKjLr2tryz0Zw30gTv3S0ET57xsCiD25WMPn3wA/s800/LIQUIDGALAXYLOGO.png" alt="picture" width="170" height="150" />
    </td>
  </tr>
  <tr>
    <td colspan="2" align="center">
      <h2><font color='#00CC99'>$title</font></h2>
    </td>
  </tr>
 
  <tr>
    <td colspan="2">
      <p><font color="#3399CC">$description</font></p>
    </td>
  </tr>
  <tr>
    <td align="center">
      <a href="#">$sources</a>
    </td>
  </tr>
  <tr>
    <td colspan="2" align="center">
      <font color="#999999">@$appname 2022</font>
    </td>
  </tr>
</table>]]></description>
		<LookAt>
			<longitude>-17.841486</longitude>
			<latitude>28.638478</latitude>
			<altitude>0</altitude>
			<heading>0</heading>
			<tilt>0</tilt>
			<range>24000</range>
		</LookAt>
		<styleUrl>#purple_paddle</styleUrl>
		<gx:balloonVisibility>1</gx:balloonVisibility>
		<Point>
			<coordinates>-17.841486,28.638478,0</coordinates>
		</Point>
	</Placemark>
</Document>
</kml>
''';
  try {
    // final client = SSHClient(
    //   await SSHSocket.connect(sshClientProvider.ip, sshClientProvider.port),
    //   username: sshClientProvider.username,
    //   onPasswordRequest: () => sshClientProvider.password,
    // );
    // sshClientProvider.client = client;
    // await sshClientProvider.client!.execute('> /var/www/html/kml/slave_3.kml');
    // await sshClientProvider.client!.execute('> /var/www/html/kml/slave_3.txt');
    await sshClientProvider.client!
        .execute("echo '$openBalloonKML' > /var/www/html/kml/slave_3.kml");
    await sshClientProvider.client!.execute(
        'echo "http://lg1:81/kml/slave_3.kml" > /var/www/html/kmls.txt');
    print('ran');
  } catch (e) {
    return Future.error(e);
  }
}

Future cleanVisualization(SSHClientProvider sshClientProvider) async {
  try {
    //  'echo "http://lg1:81/$projectname.kml"
    return await sshClientProvider.client!
        .execute('> /var/www/html/kml/slave_3.txt');
  } catch (e) {
    print('Could not connect to host LG');
    return Future.error(e);
  }
}

goToPlace(String place, SSHClientProvider sshclientprovider) async {
  try {
    await sshclientprovider.client!
        .execute('echo "search=$place" >/tmp/query.txt');
  } catch (e) {
    print('An error occurred while executing the command: $e');
  }
}

Future relaunchLG(SSHClientProvider sshClientProvider) async {
  try {
    for (var i = (sshClientProvider.rigs); i >= 1; i--) {
      final relaunchCommand = """RELAUNCH_CMD="\\
if [ -f /etc/init/lxdm.conf ]; then
  export SERVICE=lxdm
elif [ -f /etc/init/lightdm.conf ]; then
  export SERVICE=lightdm
else
  exit 1
fi
if  [[ \\\$(service \\\$SERVICE status) =~ 'stop' ]]; then
  echo ${sshClientProvider.password} | sudo -S service \\\${SERVICE} start
else
  echo ${sshClientProvider.password} | sudo -S service \\\${SERVICE} restart
fi
" && sshpass -p ${sshClientProvider.password} ssh -x -t lg@lg$i "\$RELAUNCH_CMD\"""";
      await sshClientProvider.client!.execute(
          '"/home/${sshClientProvider.username}/bin/lg-relaunch" > /home/${sshClientProvider.username}/log.txt');
      await sshClientProvider.client!.execute(relaunchCommand);
    }
  } catch (e) {
    print('Could not connect to host LG');
    return Future.error(e);
  }
}

Future setRefresh(SSHClientProvider sshClientProvider) async {
  try {
    const search = '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href>';
    const replace =
        '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href><refreshMode>onInterval<\\/refreshMode><refreshInterval>2<\\/refreshInterval>';
    final command =
        'echo ${sshClientProvider.password} | sudo -S sed -i "s/$search/$replace/" ~/earth/kml/slave/myplaces.kml';

    final clear =
        'echo ${sshClientProvider.password} | sudo -S sed -i "s/$replace/$search/" ~/earth/kml/slave/myplaces.kml';
    final client = SSHClient(
      await SSHSocket.connect(sshClientProvider.ip, sshClientProvider.port)
          .timeout(Duration(seconds: 5)),
      username: sshClientProvider.username,
      onPasswordRequest: () => sshClientProvider.password,
    );

    for (var i = 2; i <= sshClientProvider.rigs; i++) {
      final clearCmd = clear.replaceAll('{{slave}}', i.toString());
      final cmd = command.replaceAll('{{slave}}', i.toString());
      String query =
          'sshpass -p ${sshClientProvider.password} ssh -t lg$i \'{{cmd}}\'';

      await client.execute(query.replaceAll('{{cmd}}', clearCmd));
      await client.execute(query.replaceAll('{{cmd}}', cmd));
    }
  } catch (e) {
    return Future.error(e);
  }
}
