# Kubecost

In this simple example, I will show you how to set an alert via the UI, configure a budget with an alert via the UI, and how to set it up through the `values.yaml` in the Helm Chart for deployment via tools like Argo CD.

Let's consider a straightforward use case:

- **Project Budget**: $100 per month for Project X.
- **Cluster Budget**: $500 per month for the entire cluster.
- **Notification**: If any budget is exceeded, a notification should be sent to the FinOps team members.

The goal of the FinOps team is not only to track the project but also to respond promptly when costs are too high, understand these costs, and identify cost drivers without needing to be Kubernetes experts.

## Kubecost UI

If you haven't deployed Kubecost yet, there's a demo environment available that allows you to configure and test it. You can access this environment at https://demo.kubecost.io/.

We will use this demo environment to configure an alert.

### Setup Alert in the Kubecost UI

To set up alerts in the Kubecost UI, follow these steps:

1. **Navigate to the Alerts Section**: Open the Kubecost UI and go to the Alerts section.
2. **Create a New Alert**: Click on the "+ Create Alert" button.
3. **Configure Alert Parameters**: Select the type of alert you want to set up (e.g., budget, efficiency). Define the parameters such as the time window, aggregation level, filter criteria, and threshold.
4. **Set Notification Channels**: Specify the notification channels, such as email, Slack, or Microsoft Teams, by providing the necessary webhook URLs and email addresses.
5. **Save the Alert**: Review the configuration and save the alert.

Here is an example of how you can set up an alert for a alerts in the Kubecost UI:

![Kubecost UI Setup Alert](images/kubecost_ui_setup_alert.gif)

### Setup Budget + Alert in the Kubecost UI

To set up a budget with an alert in the Kubecost UI:

1. **Navigate to the Budgets Section**: Open the Kubecost UI and go to the Budgets section.
2. **Create a New Budget**: Click on the "+ Create Budget" button.
3. **Define Budget Parameters**: Enter the budget amount, select the time window (e.g., daily, weekly, monthly), and choose the aggregation level (e.g., namespace, cluster).
4. **Add Alert for the Budget**: Link the budget to an alert by configuring the alert settings. Specify the threshold at which the alert should trigger.
5. **Set Notification Channels**: Provide email addresses and webhook URLs for Slack or Microsoft Teams to receive notifications.
6. **Save the Budget and Alert**: Review the setup and save both the budget and the alert.

Here is an example of how you can set up an alert for a budget + alert in the Kubecost UI:

![Kubecost UI Setup Budget + Alert](images/kubecost_ui_budget_setup_alert.gif)

## Kubecost Helm Chart

Kubecost can be deployed using the Helm Chart, which allows you to configure alerts and budgets using the `values.yaml` file. This approach is useful for setting up alerts as code and deploying them using GitOps tools like Argo CD.

### Setup Alert over values.yaml

To set up alerts using the `values.yaml` file in the Kubecost Helm Chart:

1. **Edit values.yaml**: Open the `values.yaml` file in your preferred text editor.
2. **Add Alert Configuration**: Insert the alert configuration under the `alerts` section. Below is an example configuration:

   ```yaml
   ---
   alerts:
     - type: budget
       threshold: 100
       window: 30d
       aggregation: namespace
       filter: project-x
       ownerContact:
         - owner@example.com
       slackWebhookUrl: https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX
       msTeamsWebhookUrl: https://xxxxx.webhook.office.com/webhookb2/XXXXXXXXXXXXXXXXXXXXXXXX/IncomingWebhook/XXXXXXXXXXXXXXXXXXXXXXXX
     - type: budget
       threshold: 500
       window: 30d
       aggregation: cluster
       filter: cluster-one
   ```

3. **Apply the Helm Chart**: Deploy or update the Helm chart with the modified `values.yaml` file by running the following command:
   ```sh
   helm upgrade --install kubecost kubecost/cost-analyzer -f values.yaml -n kubecost --create-namespace
   ```
4. **Verify Alerts**: After deployment, verify that the alerts are correctly set up by checking the Kubecost UI or using the `kubectl` command to inspect the configuration.

This configuration helps the FinOps team monitor and control the spending across different namespaces and clusters, ensuring they stay within the defined budgets and can take action if spending exceeds the limits or understand the cost drivers.
