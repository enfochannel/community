<h1>Visit: https://letsencrypt.org/</h1>
<p>This script is based on the issue raised on community of let's encrypt.
<br />
<i>https://community.letsencrypt.org/t/cert-renewal-for-tomcat-server/127050</i>
</p>
<p> This is not a great idea to have web application directly hosted on a tomcat server but didn't get a time to move front end to another service and let micro service run on tomcat</p>
<p>Most appropriate approach is to have frontend deploy on somewhere like GCS and use native ssl.</p>
<p>along with this a cron job can be handy which will execute on every Sunday, 12:00 AM GMT</p>
