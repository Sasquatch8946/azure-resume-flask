# Cloud Resume Challenge With a Twist - Using a Proper Backend
One thing that bothered me with the cloud resume challenge for the longest time was the fact that the main tutorial I used had one exposing the Azure Function API key in the frontend code.

This refactor corrects that by incorporating a very simple Flask app that gets deployed to Azure App Service so it can retrieve the API URL as a secret from app settings. During local development, I load the environment variables from a .env file using the library python-dotenv.

This way, I can comfortably share my code on GitHub without feeling exposed.

I'm not sure why this isn't discussed widely. I've similarly found other Azure projects posted on GitHub that publish Azure Function keys.

I understand that many of the people who do these projects are not developers, and many of us aren't big targets for threat actors, but still, if there was ever a vulnerability in Azure Functions, we would be leaving ourselves wide open.

As admins, security should be a priority.

For historical reasons, here is [the original repo](https://github.com/Sasquatch8946/azure-resume).

# One small gotcha with Azure Front Door
Not sure why this wasn't an issue with the Azure storage static web app, but with Flask/app service, unless you add a Cache-Control header with a value of "no-store", Front Door will cache the visitor counter. Consequently, you can refresh the page over and over again and the visitor counter will remain the same. 

So, in the "view"/function that you write to handle coordinating the API call between the frontend JS and the Azure Function, I specified the Cache-Control header in the return statement. 
