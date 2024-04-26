# DBT Core & Snowflake Hands On Practices
## 2.1 Objectives
- Explain typical dbt directories structures
- Introduction to basic important files - profiles.yml, dbt_projects.yml, sources.yml, schema.yml
- How to add sources
- How to install dependencies
- Introduction of basic dbt commands like dbt run, dbt seed, dbt test, dbt docs generate, dbt docs serve, dbt show, dpt deps

## 2.2 Step-by-Step Guide
### Step 1: Sign Up for A Snowflake Trial Account
- Sign up for a Snowflake Trial Account via this [link](https://signup.snowflake.com/?utm_source=google&utm_medium=paidsearch&utm_campaign=ap-my-en-brand-productlogin-phrase&utm_content=go-rsa-evg-ss-free-trial&utm_term=c-g-snowflake%20net-p&_bt=591349680859&_bk=snowflake%20net&_bm=p&_bn=g&_bg=125204664862&gclsrc=aw.ds&gad_source=1&gclid=CjwKCAjw26KxBhBDEiwAu6KXt_n7Nh_Nk3mNBafetMGMnA7EnMRppqV-NdFloy2IZMjDWmDobW4CIRoCCtQQAvD_BwE). You will be given $400 credits and 30-days of trial period.

### Step 2: Snowflake Configuration
- Login to the newly created snowflake trial account.
- From the side panel, navigate to **Projects** > **Worksheets** and then select the **Folders** tab. Next, create a new folder - `dbt-snowflake demo` by clicking the **" + "** button on the right hand side. This folder will be used to store all the related demo worksheets. Refer to the image below for better visualisation. ![image](/images/image1.png)
- Within the folder, create a new worksheet and include the following codes:
	```sql
	-- Create Snowflake user for dbt
	USE ROLE accountadmin;
	CREATE USER IF NOT EXISTS dbt_user
	    PASSWORD = 'password'
	    LOGIN_NAME = dbt_user
	    DISPLAY_NAME = dbt_user
	    COMMENT = 'User for handling dbt development and production';
	
	-- Create new roles for dbt
	USE ROLE securityadmin;
	CREATE OR REPLACE ROLE dbt_dev_role;
	
	-- Grant the specific roles to the selected users
	GRANT ROLE dbt_dev_role TO USER dbt_user;
	GRANT ROLE dbt_dev_role TO ROLE sysadmin;
	
	-- Create snowflake virtual warehouse
	-- You can play with the warehouse's configurations
	USE ROLE sysadmin;
	CREATE OR REPLACE WAREHOUSE dbt_dev_wh WITH
	    WAREHOUSE_SIZE = 'MEDIUM'
	    AUTO_SUSPEND = 60
	    AUTO_RESUME = TRUE
	    MIN_CLUSTER_COUNT = 1
	    MAX_CLUSTER_COUNT = 1
	    INITIALLY_SUSPENDED = TRUE;
	
	-- Grant the permissions to fully access the warehouse to selected role
	GRANT ALL ON WAREHOUSE dbt_dev_wh TO ROLE dbt_dev_role;
	
	-- Create new daabase
	CREATE OR REPLACE DATABASE dbt_dev;
	
	-- Grant the permissions to fully access the database to selected role
	GRANT ALL ON DATABASE dbt_dev TO ROLE dbt_dev_role;
	```
	The above SQL script performs several administrative tasks in Snowflake:
	- Create a dbt User
	- Define Roles for dbt
	- Grant Roles
	- Set Up a Virtual Warehouse in Snowflake
	- Grant Permissions for Warehouse
	- Create a Database
	- Grant Permissions for Database

_**Remarks**_: _In this tutorial, full permissions are granted to the roles. However, in reality, it is necessary to grant only the minimal permissions or privileges that allow the tasks to be completed for each role_

### Step 3: Forking and Cloning the Repository for DBT-Snowflake Demo
- Fork this [demo-dbt-snowflake](https://github.com/jhwong97/demo-dbt-snowflake/tree/main/dbt_snowflake) repository
- Clone the forked repository to your local device.

### Step 4: Typical Directory Structures
- Once you have successfully cloned the forked repository onto your local device, navigate to the `dbt_snowflake` subfolder located within the cloned repository.
- The `dbt_snowflake` has the following directory structures:
	```cmd
	dbt_snowflake
	├── analyses
	├── dbt_project.yml
	├── macros
	├── models
	│   └── example
	│       ├── my_first_dbt_model.sql
	│       ├── my_second_dbt_model.sql
	│       └── schema.yml
	├── packages.yml
	├── profiles.yml
	├── seeds
	├── snapshots
	└── tests
	```
- The descriptions for each of the files and directories are as below:
	- `analyses`: This directory is mainly used for analytical queries but are not directly transformed into models.
	- `macros`: Macros are sets of SQL statements that you can reuse across your dbt project.
	- `models`: Contains the SQL files that define the transformations to create the analytics-ready data. Each model usually corresponds to a table or view in the database
	- `seeds`: his directory holds CSV files that dbt can load into your data warehouse as static data
	- `snapshots`: Contains SQL files that define how dbt captures changes to a specified dataset over time.
	- `tests`: This directory can be used to store custom data tests.
	- `dbt_project.yml`: The main configuration file for your dbt project. It defines project-specific configurations such as the dbt version requirement, model configurations, source data descriptions, and output settings
	- `packages.yml`: This file is used to manage dependencies of your dbt project
	- `profiles.yml`: This configuration file contains the details to connect to your data sources
	- `schema.yml`: A crucial role in defining and documenting the data models (metadata). Besides, it also helps in enforcing data quality through tests.

### Step 5: Testing dbt to Snowflake Connection
To setup the connection of this dbt repository with your personal Snowflake data warehouse, you are required to go through the following procedure:
- First, you are required to activate your virtual environment in `de-dbt-analytics` to use all the built-packages for this demo.
- After activating the virtual environment, navigate to the `dbt_snowflake` directory which is located inside the forked repository.
- Open the `profiles.yml` and you should see the below codes:
	```yml
	dbt_snowflake:
		outputs:
			dev:
				account: <organization_name>-<account_name>
				database: dbt_dev
				password: password
				role: dbt_dev_role
				schema: <schema_name>
				threads: 1
				type: snowflake
				user: dbt_user
				warehouse: dbt_dev_wh
		target: dev
	```
	- There are a few configurations that you need to amend:
		- For the `account`, you are required to replace the `<organization_name>` and `<account_name>` with your own value which can be found from your Snowflake URL after login. As example, for this Snowflake's sample URL - `https://app.snowflake.com/uavletx/htb11561/worksheets` the `<organization_name>` will be `uavletx` and the `<account_name>` is `htb11561`. Therefore, the final value will be `uavletx-htb11561`.
		- For the `schema`, you are required to replaced the `<schema_name>` with any name that suit your preferences. For example, `usr_alwong`.
	- Save the changes.
- Run the following command to test your dbt to Snowflake connections:
	```bash
	dbt debug --profiles-dir .
	```

- Run the following command to download all the dbt packages or dependencies:
	```bash
	dbt deps
	```

- Run the sample dbt models - `my_first_dbt_model.sql` and `my_second_dbt_model.sql` by executing the following command:
	```bash
	dbt run --profiles-dir .
	```
	
- Navigate to your Snowflake and under the **Data**, check if there is a new table - `MY_FIRST_DBT_MODEL` and a new view - `MY_SECOND_DBT_MODEL` created inside your schema as shown in the image below. ![image](/images/image2.png)
- If everything run successfully, Congratz! You've set up your dbt to Snowflake connections.