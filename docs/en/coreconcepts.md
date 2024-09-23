# Core Concepts of AppControl

AppControl is built on a set of core concepts that enable effective monitoring, control, and automation of your applications across both local and cloud-based environments. Understanding these concepts will help you make full use of the platform.

---

## 1. Agents

AppControl uses **agents** to interact with your local infrastructure. These agents act as the bridge between your on-premises applications and the AppControl SaaS platform. Agents can be installed on both **Windows** and **Linux** systems, allowing for flexible integration with diverse IT environments.

---

## 2. Gateway

The **gateway** is the critical link between agents deployed on your local infrastructure and the AppControl SaaS platform. It facilitates secure and reliable communication, ensuring that actions taken on your applications are synchronized with the cloud.

---

## 3. Applications

In AppControl, an **application** represents a collection of components that need to be monitored and managed. Each application is defined through a **YAML configuration file**, which describes its components and the actions that can be performed on them.

---

## 4. Components

A **component** is a critical part of an application and defines the actions that AppControl can perform. Each component is described by three primary actions: **start**, **stop**, and **check**. In addition, some components may have optional **custom commands**.

### Command Types:

-   **Check Command**: Retrieves the current state of the component.
-   **Start Command**: Starts the component, initiating processes or services.
-   **Stop Command**: Stops the component, halting processes or services.
-   **Custom Commands**: Optional commands that can be defined based on specific application requirements.

### Dependency Behavior:

-   **Parent-Child Dependencies**: Components follow a parent-child hierarchy. A component can only start if its **parent components** are already started. Similarly, a component can only stop if its **child components** are already stopped.
-   **Startup Sequence**: When starting an application, AppControl first starts the parent components and then proceeds to start their child components.
-   **Shutdown Sequence**: When stopping an application, AppControl stops child components first before stopping their parent components.

---

## 5. Diagnostics Actions (On-Demand Actions)

AppControl provides **on-demand actions**, also referred to as **diagnostics actions**, which allow you to perform manual checks or gather diagnostic information at any time.

-   **Purpose**: Diagnostics actions help troubleshoot issues, gather performance metrics, or run custom scripts on-demand without waiting for an incident to trigger automated actions.
-   **Customizable**: You can define these actions in the YAML file and provide flexible input parameters that can be edited by users as needed.
-   **Example**: A diagnostics action might involve checking log files, gathering system metrics, or testing connectivity between components.

---

## 6. Diagnostics and Issue Resolution

AppControl includes built-in diagnostics to detect and resolve common issues related to component states, particularly focusing on dependency relationships between components.

### Diagnostic Situation:

-   **Orphan Components**: AppControl identifies issues when components are in an incorrect state relative to their parent or child components. For example:
    -   **Issue 1**: A component is stopped while its parent is running.
    -   **Issue 2**: A component is running while its child components are stopped.
        In these cases, AppControl flags the issue and provides diagnostic information.

### Resolution Process:

-   **Stop Orphaned Components**: When an orphaned component is detected (i.e., a component that is running without its necessary parent components), AppControl will stop the orphaned components to maintain consistency.
    ![Resolution1](images/resolution1.png)
-   **Healthy State**: Once the issues are resolved, the system reaches a **healthy state**, ensuring all components are properly aligned with their parent-child dependencies.
    ![Resolution2](images/resolution2.png)
-   **Restart by Branch**: AppControl can restart components by "branch," ensuring that all parent and child components are properly started in sequence, maintaining the application's integrity.
    ![Restart](images/restart.png)

---

## 7. Automated Recovery Actions

In AppControl, automated recovery actions are designed with caution to prevent escalating issues. By default, **AppControl does not automatically restart components** to avoid the risk of increasing a problem. Instead, AppControl offers a flexible approach where users can define **scheduled auto-restart actions** using built-in **cron expressions**.

---

## 8. Application Monitoring Focus

AppControl is different from traditional monitoring solutions because it is **application-centric**. While other tools often focus on infrastructure (e.g., servers and networks), AppControl monitors and manages the actual **applications**, which are the heart of your business.

---

## Summary

Understanding these core concepts will enable you to effectively use AppControl to monitor, manage, and automate your applications. Whether you are working with legacy on-premises systems or cloud-native applications, AppControl’s agents, gateway, and application-centric approach offer the flexibility and control you need to maintain uptime and operational efficiency.
