# Cloud Resume Challenge With a Twist - Using a Proper Backend
One thing that bothered me with the cloud resume challenge for the longest time was the fact that the main tutorial I used had one exposing the Azure Function API key in the frontend code.

This refactor corrects that by incorporating a very simple Flask app that gets deployed to Azure App Service so it can retrieve the API URL as a secret from app settings. During local development, I load the environment variables from a .env file using the library python-dotenv.

This way, I can comfortably share my code on GitHub without feeling exposed.

I'm not sure why this isn't discussed widely. I've similarly found other Azure projects posted on GitHub that publish Azure Function keys.

I understand that many of the people who do these projects are not developers, and many of us aren't big targets for threat actors, but still, if there was ever a vulnerability in Azure Functions, we would be leaving ourselves wide open.

As admins, security should be a priority.