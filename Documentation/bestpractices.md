# Agents/Gateways configuration best practices

According to your configuration, differents badges will be displayed in the UI. The badges are indicators which are used to secure your I.S (Information System).

The badges are displayed in the **Agents** view.

![agents](../images/agentsview_badge.png)

### Protocol badges

* The first badge encourages the use of a recent version of the Tls protocol:
  
| Protocol | Badge |
|----------|--------|
| Tls13|  <img src="../images/gold_medal.png" alt="Screenshot" width="10%" height="10%" /> |
|Tls12|  <img src="../images/silver_medal.png" alt="Screenshot" width="10%" height="10%" />|
|Tls - Ssl | <img src="../images/bronze_medal.png" alt="Screenshot" width="10%" height="10%" />|

### Gateway badges

* The second badge encourages the use of a gateway to access agents. Indeed, the gateways are there to guarantee a stronger isolation at the network level and at the application level.

| Number of gateways by agent | Badge |
|----------|--------|
| At least one |  <img src="../images/gold_medal.png" alt="Screenshot" width="10%" height="10%" />  |
| None|   <img src="../images/silver_medal.png" alt="Screenshot" width="10%" height="10%" />  |

### Resilience badges
* The third badge encourages the use of several sites (at least primary and secondary). This declaration of the different sites is configured using the "trustedservers" variable in the agent's config.dat file. If "ignoretrustedservers" a "gold medal" will be displayed.

| Number of servers declared in "trustedserver" | Badge |
|----------|--------|
| At least two | <img src="../images/gold_medal.png" alt="Screenshot" width="10%" height="10%" /> |
| One | <img src="../images/silver_medal.png" alt="Screenshot" width="10%" height="10%" /> |
| None|  <img src="../images/bronze_medal.png" alt="Screenshot" width="10%" height="10%" /> |




