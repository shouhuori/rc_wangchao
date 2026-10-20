-- MySQL dump 10.13  Distrib 8.4.11, for macos27.0 (arm64)
--
-- Host: localhost    Database: notification_dispatcher
-- ------------------------------------------------------
-- Server version	8.4.11

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `attempts`
--

DROP TABLE IF EXISTS `attempts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attempts` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `step_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `number` int unsigned NOT NULL,
  `token` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL,
  `request` json DEFAULT NULL,
  `response` json DEFAULT NULL,
  `status_code` int unsigned DEFAULT NULL,
  `duration_ms` int unsigned DEFAULT NULL,
  `error` text COLLATE utf8mb4_unicode_ci,
  `finished_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `attempts_step_id_number_unique` (`step_id`,`number`),
  CONSTRAINT `attempts_step_id_foreign` FOREIGN KEY (`step_id`) REFERENCES `request_steps` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attempts`
--

LOCK TABLES `attempts` WRITE;
/*!40000 ALTER TABLE `attempts` DISABLE KEYS */;
INSERT INTO `attempts` VALUES ('01a15586-04b6-706e-a379-9dd72ae4fe38','01a15586-040c-7268-9712-9d665743ae25',1,'3fbe8436-0926-45c3-93bd-0544926051a7','succeeded','{\"url\": \"http://127.0.0.1:9081/reserve\", \"body\": {\"order_id\": \"demo-success\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"238ef269-765e-4662-ac8a-47cefc5c7791\"}}','{\"id\": \"contact-fe776065\", \"ok\": true, \"operation\": \"/reserve\"}',200,31,NULL,'2026-10-19 10:56:48','2026-10-19 10:56:48','2026-10-19 10:56:48'),('01a15586-04b9-7314-8ea1-f9b0d4c75e37','01a15586-040d-7014-8bf1-bfd5bc2084e4',1,'396748f1-5daf-4c62-ae2d-0c1142d0de6b','succeeded','{\"url\": \"http://127.0.0.1:9081/contacts\", \"body\": {\"contact_id\": \"contact-demo\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"0e732506-1a5c-4170-bbb9-9c8c96f84b87\"}}','{\"id\": \"contact-demo\", \"ok\": true, \"operation\": \"/contacts\"}',200,28,NULL,'2026-10-19 10:56:48','2026-10-19 10:56:48','2026-10-19 10:56:48'),('01a15586-08ab-70d1-acc2-890fb79a7924','01a15586-040f-700d-99be-dc05890c844e',1,'80454b99-40d4-48d0-92af-d754296bcce1','succeeded','{\"url\": \"http://127.0.0.1:9081/sms\", \"body\": {\"order_id\": \"demo-success\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"e7796de3-67d1-40b2-9968-3352bcae2515\"}}','{\"id\": \"contact-0c6b0344\", \"ok\": true, \"operation\": \"/sms\"}',200,13,NULL,'2026-10-19 10:56:49','2026-10-19 10:56:49','2026-10-19 10:56:49'),('01a15586-08f4-72b6-a942-6a02d7de3d15','01a15586-040e-70b4-9c92-6f36e04af4d3',1,'f61246f0-ce6b-4b66-b195-905b6fdc827d','succeeded','{\"url\": \"http://127.0.0.1:9081/paid\", \"body\": {\"order_id\": \"demo-success\", \"contact_id\": \"contact-demo\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"d5a669d4-cb40-4487-a835-9edda9bde777\"}}','{\"id\": \"contact-demo\", \"ok\": true, \"operation\": \"/paid\"}',200,4,NULL,'2026-10-19 10:56:49','2026-10-19 10:56:49','2026-10-19 10:56:49'),('01a15587-d771-7320-8d0e-de54aa1bf8f7','01a15586-0411-7060-942c-f78746804f00',1,'69ba5d31-a7e6-4a04-9cf5-1cb52b34d947','retry','{\"url\": \"http://127.0.0.1:9081/reserve\", \"body\": {\"order_id\": \"demo-retry\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"c9a3a58b-0eb4-46e2-adf8-449442f6632d\"}}','{\"error\": \"演示：临时不可用\"}',503,26,'HTTP 503：可重试错误。','2026-10-19 10:58:48','2026-10-19 10:58:48','2026-10-19 10:58:48'),('01a15587-d771-7398-8c80-e8dff4fd78f7','01a15586-0412-7081-ad95-4519e0219923',1,'c3a2c433-b5a1-4c19-8301-b0194a8d33b9','succeeded','{\"url\": \"http://127.0.0.1:9081/contacts\", \"body\": {\"contact_id\": \"contact-demo\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"23baf2df-835a-48f6-b18e-9019ed12049a\"}}','{\"id\": \"contact-demo\", \"ok\": true, \"operation\": \"/contacts\"}',200,26,NULL,'2026-10-19 10:58:48','2026-10-19 10:58:48','2026-10-19 10:58:48'),('01a15587-db9c-709c-a550-1b3ec59cb3a8','01a15586-0413-70bc-ae1f-b8c8c6577b8a',1,'50dcba98-5ea2-47f3-92eb-9786396793bf','succeeded','{\"url\": \"http://127.0.0.1:9081/paid\", \"body\": {\"order_id\": \"demo-retry\", \"contact_id\": \"contact-demo\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"1bbf8c70-b1b8-4d00-a844-46586659cc9f\"}}','{\"id\": \"contact-demo\", \"ok\": true, \"operation\": \"/paid\"}',200,4,NULL,'2026-10-19 10:58:49','2026-10-19 10:58:49','2026-10-19 10:58:49'),('01a15587-db9e-72c7-95ff-8df0aa0bfa11','01a15586-0417-7217-8f18-186286e7ba15',1,'0313c08c-4db9-4397-8f9b-06f42a9193bd','dead','{\"url\": \"http://127.0.0.1:9081/reserve\", \"body\": {\"order_id\": \"demo-dead\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"3b48ff23-2f2f-43ad-a49c-a0c6d7ce9bff\"}}','{\"error\": \"演示：商品不可售\"}',400,3,'HTTP 400：请求被拒绝或业务结果未满足成功条件。','2026-10-19 10:58:49','2026-10-19 10:58:49','2026-10-19 10:58:49'),('01a15587-dfb6-725c-b447-ebe14b0e7e90','01a15586-041c-730f-90bb-a0c3de409b5e',1,'1a151ea7-0883-4644-913f-c11e656831b0','unknown','{\"url\": \"http://127.0.0.1:9081/reserve\", \"body\": {\"order_id\": \"demo-unknown\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"dc733340-a5c7-4b67-b543-150c25de1083\"}}','{\"accepted\": true}',202,9,'HTTP 202：仅确认受理，需核对完成状态。','2026-10-19 10:58:50','2026-10-19 10:58:50','2026-10-19 10:58:50'),('01a15587-dfb8-73ea-9317-101da89751d5','01a15586-0418-7256-be9e-528e8f4b540b',1,'9245a465-6dcb-4877-94ec-f016159c1a52','succeeded','{\"url\": \"http://127.0.0.1:9081/contacts\", \"body\": {\"contact_id\": \"contact-demo\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"06305f72-936b-4fec-af66-666d89cb7781\"}}','{\"id\": \"contact-demo\", \"ok\": true, \"operation\": \"/contacts\"}',200,8,NULL,'2026-10-19 10:58:50','2026-10-19 10:58:50','2026-10-19 10:58:50'),('01a15587-e3d1-7115-b58a-21cbd8f23050','01a15586-0419-71db-b0df-29e76e88f71b',1,'cefd9797-f141-44f6-9d4a-c9c2126b5b84','succeeded','{\"url\": \"http://127.0.0.1:9081/paid\", \"body\": {\"order_id\": \"demo-dead\", \"contact_id\": \"contact-demo\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"c5bf219d-3318-4a75-a033-0dd40cdf7a3c\"}}','{\"id\": \"contact-demo\", \"ok\": true, \"operation\": \"/paid\"}',200,5,NULL,'2026-10-19 10:58:51','2026-10-19 10:58:51','2026-10-19 10:58:51'),('01a15587-e7e9-735d-bea4-ffc550a4b019','01a15586-041d-73ec-9fad-e895e090e247',1,'81b2e5ad-881d-4c9d-937d-3e615ff0177d','succeeded','{\"url\": \"http://127.0.0.1:9081/contacts\", \"body\": {\"contact_id\": \"contact-demo\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"c318c921-ecdb-46e4-b1e3-29d4e1f2ca69\"}}','{\"id\": \"contact-demo\", \"ok\": true, \"operation\": \"/contacts\"}',200,7,NULL,'2026-10-19 10:58:52','2026-10-19 10:58:52','2026-10-19 10:58:52'),('01a15587-ebfc-703d-a0bd-2c9e8b309d2e','01a15586-041d-73ec-9fad-e895e105b0a1',1,'cd6d8b46-0d3c-4b29-b38f-a7931a349699','succeeded','{\"url\": \"http://127.0.0.1:9081/paid\", \"body\": {\"order_id\": \"demo-unknown\", \"contact_id\": \"contact-demo\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"d2d992b0-65e5-4677-84af-6a153414d059\"}}','{\"id\": \"contact-demo\", \"ok\": true, \"operation\": \"/paid\"}',200,6,NULL,'2026-10-19 10:58:53','2026-10-19 10:58:53','2026-10-19 10:58:53'),('01a15587-ff50-724e-9aab-3acb46e4abaf','01a15586-0411-7060-942c-f78746804f00',2,'1e4955cf-0a94-4b20-b4a7-46f4632b9ddf','succeeded','{\"url\": \"http://127.0.0.1:9081/reserve\", \"body\": {\"order_id\": \"demo-retry\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"c9a3a58b-0eb4-46e2-adf8-449442f6632d\"}}','{\"id\": \"contact-a516d66d\", \"ok\": true, \"operation\": \"/reserve\"}',200,5,NULL,'2026-10-19 10:58:58','2026-10-19 10:58:58','2026-10-19 10:58:58'),('01a15588-0693-71f2-ac44-eed541246c85','01a15586-0414-72ff-9972-3e45ced5fdcf',1,'26bfc231-36fc-4b97-b094-db9a613afe18','succeeded','{\"url\": \"http://127.0.0.1:9081/sms\", \"body\": {\"order_id\": \"demo-retry\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"6e3eefb1-0dc2-4503-b61d-2912a62b9067\"}}','{\"id\": \"contact-c515083c\", \"ok\": true, \"operation\": \"/sms\"}',200,21,NULL,'2026-10-19 10:59:00','2026-10-19 10:59:00','2026-10-19 10:59:00'),('01a15592-7656-73f5-ae71-2e5913c68bbc','01a15592-72de-7152-992e-cf6de93f1cbd',1,'c2429d1c-6333-415e-b4f2-5e49e4aba770','succeeded','{\"url\": \"http://127.0.0.1:9081/reserve\", \"body\": {\"order_id\": \"demo-success\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"535210ac-2603-488e-b32d-c7420e4ab03e\"}}','{\"id\": \"contact-4979cddd\", \"ok\": true, \"operation\": \"/reserve\"}',200,24,NULL,'2026-10-19 11:10:24','2026-10-19 11:10:24','2026-10-19 11:10:24'),('01a15592-7659-7025-a0ab-ccfccaf77207','01a15592-72e0-7228-82d1-cac9d88fad39',1,'2046c195-f53d-4c73-841b-0f0105724096','succeeded','{\"url\": \"http://127.0.0.1:9081/contacts\", \"body\": {\"contact_id\": \"contact-demo\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"99819894-e896-40c8-bd5e-844903052dee\"}}','{\"id\": \"contact-demo\", \"ok\": true, \"operation\": \"/contacts\"}',200,22,NULL,'2026-10-19 11:10:24','2026-10-19 11:10:24','2026-10-19 11:10:24'),('01a15592-7a3d-73f3-b125-f759bbfa5d95','01a15592-72e3-72ef-8a2e-11067220375f',1,'3076e0a6-2339-4273-b86b-f106ab957a76','succeeded','{\"url\": \"http://127.0.0.1:9081/sms\", \"body\": {\"order_id\": \"demo-success\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"31f52201-308c-49c9-87a1-46130485eac2\"}}','{\"id\": \"contact-3d8570a0\", \"ok\": true, \"operation\": \"/sms\"}',200,14,NULL,'2026-10-19 11:10:25','2026-10-19 11:10:25','2026-10-19 11:10:25'),('01a15592-7e61-72ad-8832-ad5f63e7b244','01a15592-72e1-7054-8a2e-5d6c4752274a',1,'4349f2e7-dde8-4bed-b004-2e9f57007f20','succeeded','{\"url\": \"http://127.0.0.1:9081/paid\", \"body\": {\"order_id\": \"demo-success\", \"contact_id\": \"contact-demo\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"33088535-9071-42e2-bfee-c7e615cd2c80\"}}','{\"id\": \"contact-demo\", \"ok\": true, \"operation\": \"/paid\"}',200,6,NULL,'2026-10-19 11:10:26','2026-10-19 11:10:26','2026-10-19 11:10:26'),('01a15592-7e61-7391-b208-2c4b191c1277','01a15592-72e6-729d-844b-01d3dfaa52a6',1,'eddff342-0261-44da-aaa3-468276ea88a2','retry','{\"url\": \"http://127.0.0.1:9081/reserve\", \"body\": {\"order_id\": \"demo-retry\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"031bc79b-67f6-422b-9057-c7b2508581b5\"}}','{\"error\": \"演示：临时不可用\"}',503,6,'HTTP 503：可重试错误。','2026-10-19 11:10:26','2026-10-19 11:10:26','2026-10-19 11:10:26'),('01a15592-865c-714a-9933-89203dee0db3','01a15592-72e8-73f2-bafd-697d6808309a',1,'b64b274d-88ff-4222-9d1a-bbe02b4f5e86','succeeded','{\"url\": \"http://127.0.0.1:9081/contacts\", \"body\": {\"contact_id\": \"contact-demo\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"f8bd4111-2f74-4cf1-b7b5-e82ad3231995\"}}','{\"id\": \"contact-demo\", \"ok\": true, \"operation\": \"/contacts\"}',200,6,NULL,'2026-10-19 11:10:28','2026-10-19 11:10:28','2026-10-19 11:10:28'),('01a15592-865c-71fa-ba59-e792084c6d0b','01a15592-72ed-7039-b4a4-b5167c78ffd5',1,'3d01f41f-37e7-4724-bdb2-51cec8bcc3ed','dead','{\"url\": \"http://127.0.0.1:9081/reserve\", \"body\": {\"order_id\": \"demo-dead\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"ec7bae27-d190-40d8-a17c-2008f832fb2e\"}}','{\"error\": \"演示：商品不可售\"}',400,6,'HTTP 400：请求被拒绝或业务结果未满足成功条件。','2026-10-19 11:10:28','2026-10-19 11:10:28','2026-10-19 11:10:28'),('01a15592-8e61-711b-9f4e-da980651af08','01a15592-72e9-7317-8151-af573dcdde54',1,'28532cf8-9b45-4f95-8b92-b5b5d37f7fb6','succeeded','{\"url\": \"http://127.0.0.1:9081/paid\", \"body\": {\"order_id\": \"demo-retry\", \"contact_id\": \"contact-demo\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"0f4b2165-c00f-44b7-a5ff-5930dea249e4\"}}','{\"id\": \"contact-demo\", \"ok\": true, \"operation\": \"/paid\"}',200,7,NULL,'2026-10-19 11:10:30','2026-10-19 11:10:30','2026-10-19 11:10:30'),('01a15592-8e65-701f-ad47-51a01d52b91d','01a15592-72f4-7201-9cd4-a6d68208d198',1,'8747ee16-20fa-4298-b39e-25beb2609c44','unknown','{\"url\": \"http://127.0.0.1:9081/reserve\", \"body\": {\"order_id\": \"demo-unknown\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"4056e630-9eae-40d9-9d65-5c4a044bccd6\"}}','{\"accepted\": true}',202,6,'HTTP 202：仅确认受理，需核对完成状态。','2026-10-19 11:10:30','2026-10-19 11:10:30','2026-10-19 11:10:30'),('01a15592-9662-7004-a6d0-023a7ca4c0f9','01a15592-72ee-721c-ad1f-907e6f0c8f77',1,'90a12708-afb4-4dd0-8e22-9d1ccaa0085b','succeeded','{\"url\": \"http://127.0.0.1:9081/contacts\", \"body\": {\"contact_id\": \"contact-demo\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"0ffbcb9e-268c-4a8f-86d1-816fb7894294\"}}','{\"id\": \"contact-demo\", \"ok\": true, \"operation\": \"/contacts\"}',200,6,NULL,'2026-10-19 11:10:32','2026-10-19 11:10:32','2026-10-19 11:10:32'),('01a15592-9e63-73ae-8ea9-d82f9e031b5f','01a15592-72ef-72ab-baa6-b0e0254b3ce6',1,'dd1d21ef-8e65-4934-b367-cd746f810dfc','succeeded','{\"url\": \"http://127.0.0.1:9081/paid\", \"body\": {\"order_id\": \"demo-dead\", \"contact_id\": \"contact-demo\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"17fd5941-94a4-4b67-bbb8-8e287f50a893\"}}','{\"id\": \"contact-demo\", \"ok\": true, \"operation\": \"/paid\"}',200,5,NULL,'2026-10-19 11:10:34','2026-10-19 11:10:34','2026-10-19 11:10:34'),('01a15592-a660-722c-9d63-b6fb02d7350e','01a15592-72f5-70db-abf0-ac45367419e8',1,'0206a447-0d86-4fe4-a47e-a5a961f740fe','succeeded','{\"url\": \"http://127.0.0.1:9081/contacts\", \"body\": {\"contact_id\": \"contact-demo\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"db52c25a-4687-402a-8ccf-dba7dfcd99d7\"}}','{\"id\": \"contact-demo\", \"ok\": true, \"operation\": \"/contacts\"}',200,7,NULL,'2026-10-19 11:10:36','2026-10-19 11:10:36','2026-10-19 11:10:36'),('01a15592-adf8-7052-95cc-7296d8a7a77b','01a15592-72e6-729d-844b-01d3dfaa52a6',2,'f6d7f4fe-11eb-4023-a4f9-61a3ec6c4a37','succeeded','{\"url\": \"http://127.0.0.1:9081/reserve\", \"body\": {\"order_id\": \"demo-retry\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"031bc79b-67f6-422b-9057-c7b2508581b5\"}}','{\"id\": \"contact-95beeb07\", \"ok\": true, \"operation\": \"/reserve\"}',200,5,NULL,'2026-10-19 11:10:38','2026-10-19 11:10:38','2026-10-19 11:10:38'),('01a15592-ae5a-72be-8bd0-d159b0c7c15c','01a15592-72f5-70db-abf0-ac453733005a',1,'e77fcd8f-0c2a-47c6-aac6-5ad9845d2896','succeeded','{\"url\": \"http://127.0.0.1:9081/paid\", \"body\": {\"order_id\": \"demo-unknown\", \"contact_id\": \"contact-demo\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"68a998bf-ac3c-4776-907c-e09d29fd6c6b\"}}','{\"id\": \"contact-demo\", \"ok\": true, \"operation\": \"/paid\"}',200,5,NULL,'2026-10-19 11:10:38','2026-10-19 11:10:38','2026-10-19 11:10:38'),('01a15592-b16e-723b-912c-4b02d302169a','01a15592-72eb-700f-bfa9-db0245be2600',1,'19e2e2e2-b887-4ef4-8469-0c297875fa74','succeeded','{\"url\": \"http://127.0.0.1:9081/sms\", \"body\": {\"order_id\": \"demo-retry\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"5c407f72-8b3e-43ae-a24d-a93c4275f846\"}}','{\"id\": \"contact-2dce049a\", \"ok\": true, \"operation\": \"/sms\"}',200,6,NULL,'2026-10-19 11:10:39','2026-10-19 11:10:39','2026-10-19 11:10:39'),('01a155a5-a49c-7249-8bf2-ffb709a68f4d','01a155a5-a2ad-7284-9017-cbc4e910a2de',1,'1c808e04-40a4-4d36-b71e-9006344db68a','succeeded','{\"url\": \"http://127.0.0.1:9081/reserve\", \"body\": {\"order_id\": \"demo-success\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"X-Key-Id\": \"local-demo\", \"X-Signature\": \"[已隐藏]\", \"X-Timestamp\": \"1792438281\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"277fbca7-7c5d-4340-9516-4ddeb702f8a9\"}}','{\"id\": \"contact-93efca8d\", \"ok\": true, \"operation\": \"/reserve\"}',200,28,NULL,'2026-10-19 11:31:21','2026-10-19 11:31:21','2026-10-19 11:31:21'),('01a155a5-a49e-714b-af22-e83053fc89f7','01a155a5-a2b0-72a7-b94e-49d5687efc58',1,'72b10458-bc84-4a87-8a47-37d745d19579','succeeded','{\"url\": \"http://127.0.0.1:9081/contacts\", \"body\": {\"external_id\": \"contact-demo\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Authorization\": \"[已隐藏]\", \"Idempotency-Key\": \"00f055b5-fbde-42bb-a249-716fe3b836a9\"}}','{\"id\": \"contact-demo\", \"ok\": true, \"operation\": \"/contacts\"}',200,27,NULL,'2026-10-19 11:31:21','2026-10-19 11:31:21','2026-10-19 11:31:21'),('01a155a5-a88a-726d-8a35-623903dd3712','01a155a5-a2b2-7166-bb97-24da38dda7c7',1,'e0d9df8b-5c07-43ad-9411-67c82ab84200','succeeded','{\"url\": \"http://127.0.0.1:9081/sms\", \"body\": {\"order_id\": \"demo-success\", \"template\": \"order.confirmed\", \"request_id\": \"e0b717af-003d-4a9e-af19-738c590b67a2\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"X-Api-Key\": \"[已隐藏]\", \"Content-Type\": \"application/x-www-form-urlencoded\", \"Idempotency-Key\": \"e0b717af-003d-4a9e-af19-738c590b67a2\"}}','{\"id\": \"contact-4706cf21\", \"ok\": true, \"operation\": \"/sms\"}',200,15,NULL,'2026-10-19 11:31:22','2026-10-19 11:31:22','2026-10-19 11:31:22'),('01a155a5-a8b5-70fd-84aa-a1ee0e7cd3df','01a155a5-a2b6-723b-bf70-f11a5765e910',1,'96b48f43-8081-467f-bbf5-6a2b7059ad19','retry','{\"url\": \"http://127.0.0.1:9081/reserve\", \"body\": {\"order_id\": \"demo-retry\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"X-Key-Id\": \"local-demo\", \"X-Signature\": \"[已隐藏]\", \"X-Timestamp\": \"1792438282\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"93b429e1-0965-4224-bd19-37903c7156ed\"}}','{\"error\": \"演示：临时不可用\"}',503,4,'HTTP 503：可重试错误。','2026-10-19 11:31:22','2026-10-19 11:31:22','2026-10-19 11:31:22'),('01a155a5-a8b9-7024-b092-4140afb020e5','01a155a5-a2b1-7244-9521-1a8247c1a8fe',1,'a07941a6-918e-4379-9df3-c54299452b9d','succeeded','{\"url\": \"http://127.0.0.1:9081/contacts/contact-demo/paid\", \"body\": {\"status\": \"paid\", \"order_id\": \"demo-success\", \"contact_id\": \"contact-demo\"}, \"method\": \"PATCH\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Authorization\": \"[已隐藏]\", \"Idempotency-Key\": \"1afee0f7-803f-475d-8ad1-245c6507655a\"}}','{\"id\": \"contact-demo\", \"ok\": true, \"operation\": \"/contacts/contact-demo/paid\"}',200,3,NULL,'2026-10-19 11:31:22','2026-10-19 11:31:22','2026-10-19 11:31:22'),('01a155a5-acc3-7118-9658-c443144ef828','01a155a5-a2bd-724e-ac12-713a05c37750',1,'010f0783-ff6f-4842-a6b5-ced7fe8c1f92','dead','{\"url\": \"http://127.0.0.1:9081/reserve\", \"body\": {\"order_id\": \"demo-dead\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"X-Key-Id\": \"local-demo\", \"X-Signature\": \"[已隐藏]\", \"X-Timestamp\": \"1792438283\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"9a9aa514-37f5-4b6d-a13a-49c7cd094da3\"}}','{\"error\": \"演示：商品不可售\"}',400,8,'HTTP 400：请求被拒绝或业务结果未满足成功条件。','2026-10-19 11:31:23','2026-10-19 11:31:23','2026-10-19 11:31:23'),('01a155a5-acc4-73c1-849e-85f691072256','01a155a5-a2b8-72ca-a7e4-860d2df300b8',1,'0d99eb4c-0bb7-410a-8bd1-ef9d340e0037','succeeded','{\"url\": \"http://127.0.0.1:9081/contacts\", \"body\": {\"external_id\": \"contact-demo\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Authorization\": \"[已隐藏]\", \"Idempotency-Key\": \"bda7bc38-3d3b-4371-ad8a-aa34758e9987\"}}','{\"id\": \"contact-demo\", \"ok\": true, \"operation\": \"/contacts\"}',200,8,NULL,'2026-10-19 11:31:23','2026-10-19 11:31:23','2026-10-19 11:31:23'),('01a155a5-b0d4-7206-9ce8-6146347d3035','01a155a5-a2b9-7075-be94-2292a5baf9c8',1,'cd333e60-79a9-44a4-b266-b14fd8834c38','succeeded','{\"url\": \"http://127.0.0.1:9081/contacts/contact-demo/paid\", \"body\": {\"status\": \"paid\", \"order_id\": \"demo-retry\", \"contact_id\": \"contact-demo\"}, \"method\": \"PATCH\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Authorization\": \"[已隐藏]\", \"Idempotency-Key\": \"7ca96588-0a74-4f58-8eb5-fe0efae0a4ac\"}}','{\"id\": \"contact-demo\", \"ok\": true, \"operation\": \"/contacts/contact-demo/paid\"}',200,8,NULL,'2026-10-19 11:31:24','2026-10-19 11:31:24','2026-10-19 11:31:24'),('01a155a5-b0dd-716c-88df-e17f64d6dc5e','01a155a5-a2c4-71f4-988c-47dd68135084',1,'237c836c-058c-44fc-a758-0320f44ea245','unknown','{\"url\": \"http://127.0.0.1:9081/reserve\", \"body\": {\"order_id\": \"demo-unknown\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"X-Key-Id\": \"local-demo\", \"X-Signature\": \"[已隐藏]\", \"X-Timestamp\": \"1792438284\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"788c77c6-1bb2-45ce-be2d-cec5792a56f7\"}}','{\"accepted\": true}',202,5,'HTTP 202：仅确认受理，需核对完成状态。','2026-10-19 11:31:24','2026-10-19 11:31:24','2026-10-19 11:31:24'),('01a155a5-b4e8-7365-bb32-7230d0b94ff6','01a155a5-a2bf-72c9-bbe9-3cd52cb965d1',1,'6ccff33a-7cb6-4bbb-a47e-e1947fb3eefb','succeeded','{\"url\": \"http://127.0.0.1:9081/contacts\", \"body\": {\"external_id\": \"contact-demo\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Authorization\": \"[已隐藏]\", \"Idempotency-Key\": \"1288024d-7a31-4f89-a983-22770c2f354f\"}}','{\"id\": \"contact-demo\", \"ok\": true, \"operation\": \"/contacts\"}',200,7,NULL,'2026-10-19 11:31:25','2026-10-19 11:31:25','2026-10-19 11:31:25'),('01a155a5-b8fb-738b-93d2-51ff75d2818f','01a155a5-a2bf-72c9-bbe9-3cd52d776b06',1,'2e280a43-d9e2-49b6-ac80-0865b5e1e9c2','succeeded','{\"url\": \"http://127.0.0.1:9081/contacts/contact-demo/paid\", \"body\": {\"status\": \"paid\", \"order_id\": \"demo-dead\", \"contact_id\": \"contact-demo\"}, \"method\": \"PATCH\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Authorization\": \"[已隐藏]\", \"Idempotency-Key\": \"262eecb5-e1ad-415b-8679-706628ccce1b\"}}','{\"id\": \"contact-demo\", \"ok\": true, \"operation\": \"/contacts/contact-demo/paid\"}',200,6,NULL,'2026-10-19 11:31:26','2026-10-19 11:31:26','2026-10-19 11:31:26'),('01a155a5-bd0e-7026-8ae0-9e5da904ea02','01a155a5-a2c5-713d-b37d-8f4aced614d9',1,'093b31eb-b33d-4222-abbe-3b5dfc2703fc','succeeded','{\"url\": \"http://127.0.0.1:9081/contacts\", \"body\": {\"external_id\": \"contact-demo\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Authorization\": \"[已隐藏]\", \"Idempotency-Key\": \"88f61ea9-001e-472b-b0a6-d0f73ead681c\"}}','{\"id\": \"contact-demo\", \"ok\": true, \"operation\": \"/contacts\"}',200,7,NULL,'2026-10-19 11:31:27','2026-10-19 11:31:27','2026-10-19 11:31:27'),('01a155a5-c11f-703b-bc19-f486db57a3c0','01a155a5-a2c6-723c-9be1-3cc7ef0ff6eb',1,'17969b05-309e-421b-8799-28c3288f534e','succeeded','{\"url\": \"http://127.0.0.1:9081/contacts/contact-demo/paid\", \"body\": {\"status\": \"paid\", \"order_id\": \"demo-unknown\", \"contact_id\": \"contact-demo\"}, \"method\": \"PATCH\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Authorization\": \"[已隐藏]\", \"Idempotency-Key\": \"dd695baf-d4b3-4c88-b9d0-093089cd7513\"}}','{\"id\": \"contact-demo\", \"ok\": true, \"operation\": \"/contacts/contact-demo/paid\"}',200,6,NULL,'2026-10-19 11:31:28','2026-10-19 11:31:28','2026-10-19 11:31:28'),('01a155a5-dc32-70bd-97c0-c84dbd1d89cd','01a155a5-a2b6-723b-bf70-f11a5765e910',2,'a4b1eacb-f858-43fb-80ef-f546446d58af','succeeded','{\"url\": \"http://127.0.0.1:9081/reserve\", \"body\": {\"order_id\": \"demo-retry\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"X-Key-Id\": \"local-demo\", \"X-Signature\": \"[已隐藏]\", \"X-Timestamp\": \"1792438295\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"93b429e1-0965-4224-bd19-37903c7156ed\"}}','{\"id\": \"contact-75b0e6a9\", \"ok\": true, \"operation\": \"/reserve\"}',200,5,NULL,'2026-10-19 11:31:35','2026-10-19 11:31:35','2026-10-19 11:31:35'),('01a155a5-dfc2-72c6-ac95-6a9798d23472','01a155a5-a2ba-71ed-aef5-0f50a4428eee',1,'aa0a7426-7e75-47c4-bebc-4a9c107ecd6c','succeeded','{\"url\": \"http://127.0.0.1:9081/sms\", \"body\": {\"order_id\": \"demo-retry\", \"template\": \"order.confirmed\", \"request_id\": \"450a823b-46a4-4800-9485-ce231ef706a1\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"X-Api-Key\": \"[已隐藏]\", \"Content-Type\": \"application/x-www-form-urlencoded\", \"Idempotency-Key\": \"450a823b-46a4-4800-9485-ce231ef706a1\"}}','{\"id\": \"contact-2ca19e6f\", \"ok\": true, \"operation\": \"/sms\"}',200,7,NULL,'2026-10-19 11:31:36','2026-10-19 11:31:36','2026-10-19 11:31:36'),('01a15778-6025-711c-bfea-5812bc207a87','01a15778-5f0d-733a-8755-83f3cc04c776',1,'81194c62-dfd1-4abb-88ac-2fe1982c56cc','succeeded','{\"url\": \"http://127.0.0.1:9081/contacts\", \"body\": {\"external_id\": \"timestamp-contact\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Authorization\": \"[已隐藏]\", \"Idempotency-Key\": \"1c049b0f-a1b1-4986-9c62-f66cf8b2fbb8\"}}','{\"id\": \"timestamp-contact\", \"ok\": true, \"operation\": \"/contacts\"}',200,20,NULL,'2026-10-19 20:01:09','2026-10-19 20:01:09','2026-10-19 20:01:09'),('01a15778-6027-70fe-bd33-88637fdfcd87','01a15778-5f0a-72de-8b42-dbf23df55030',1,'5117db1d-8473-45b5-a8a5-fcba32472804','succeeded','{\"url\": \"http://127.0.0.1:9081/reserve\", \"body\": {\"order_id\": \"timestamp-check\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"X-Key-Id\": \"local-demo\", \"X-Signature\": \"[已隐藏]\", \"X-Timestamp\": \"1792468869\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"6aed0db2-46ff-4843-a2c8-13f575641acc\"}}','{\"id\": \"contact-1b1cd595\", \"ok\": true, \"operation\": \"/reserve\"}',200,18,NULL,'2026-10-19 20:01:09','2026-10-19 20:01:09','2026-10-19 20:01:09'),('01a15778-652e-7374-98f7-7a2d92102f78','01a15778-5f10-7365-8f39-36f852bd7928',1,'8e208a66-7e9d-438b-a399-90e130316cf7','succeeded','{\"url\": \"http://127.0.0.1:9081/sms\", \"body\": {\"order_id\": \"timestamp-check\", \"template\": \"order.confirmed\", \"request_id\": \"2db84ad0-7449-4302-a731-7ce855321b9a\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"X-Api-Key\": \"[已隐藏]\", \"Content-Type\": \"application/x-www-form-urlencoded\", \"Idempotency-Key\": \"2db84ad0-7449-4302-a731-7ce855321b9a\"}}','{\"id\": \"contact-9e6ed0fa\", \"ok\": true, \"operation\": \"/sms\"}',200,16,NULL,'2026-10-19 20:01:10','2026-10-19 20:01:10','2026-10-19 20:01:10'),('01a15778-6836-70cb-b872-a9a34659caec','01a15778-5f0e-7275-a1ce-2387045baad8',1,'24029663-240c-4f74-b805-48eef03b10b4','succeeded','{\"url\": \"http://127.0.0.1:9081/contacts/timestamp-contact/paid\", \"body\": {\"status\": \"paid\", \"order_id\": \"timestamp-check\", \"contact_id\": \"timestamp-contact\"}, \"method\": \"PATCH\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Authorization\": \"[已隐藏]\", \"Idempotency-Key\": \"8d131ca0-9f8b-4d6b-9def-1c80a5540ad2\"}}','{\"id\": \"timestamp-contact\", \"ok\": true, \"operation\": \"/contacts/timestamp-contact/paid\"}',200,8,NULL,'2026-10-19 20:01:11','2026-10-19 20:01:11','2026-10-19 20:01:11'),('01a15787-5901-72ac-bf58-3e286fef29e8','01a15787-57fe-73a0-9e4c-07bfc113db72',1,'6a4a1193-053a-4c76-93c5-2204b85e695e','succeeded','{\"url\": \"http://127.0.0.1:9081/reserve\", \"body\": {\"order_id\": \"source-auth-check\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"X-Key-Id\": \"local-demo\", \"X-Signature\": \"[已隐藏]\", \"X-Timestamp\": \"1792469850\", \"Content-Type\": \"application/json\", \"Idempotency-Key\": \"ad8d4060-38fd-4920-a64c-62b9c3cbe6f4\"}}','{\"id\": \"contact-37ef8294\", \"ok\": true, \"operation\": \"/reserve\"}',200,17,NULL,'2026-10-19 20:17:30','2026-10-19 20:17:30','2026-10-19 20:17:30'),('01a15787-5905-73b7-b3c4-479f01a3210c','01a15787-5800-7116-a1e6-67656253b87e',1,'4babb1f2-941a-4e45-ae39-3146edd8cd06','succeeded','{\"url\": \"http://127.0.0.1:9081/contacts\", \"body\": {\"external_id\": \"contact-source\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Authorization\": \"[已隐藏]\", \"Idempotency-Key\": \"d9c6e704-03b4-408c-8793-f883bf3a88a9\"}}','{\"id\": \"contact-source\", \"ok\": true, \"operation\": \"/contacts\"}',200,14,NULL,'2026-10-19 20:17:30','2026-10-19 20:17:30','2026-10-19 20:17:30'),('01a15787-5cf6-7113-a6e4-d0b0a7dfdce0','01a15787-5804-707f-8191-f189bcd47c1a',1,'0c064681-3227-4125-bb09-6e117c4818fc','succeeded','{\"url\": \"http://127.0.0.1:9081/sms\", \"body\": {\"order_id\": \"source-auth-check\", \"template\": \"order.confirmed\", \"request_id\": \"76b1d337-57a7-48ee-8569-8092c87fe8a3\"}, \"method\": \"POST\", \"headers\": {\"Accept\": \"application/json\", \"X-Api-Key\": \"[已隐藏]\", \"Content-Type\": \"application/x-www-form-urlencoded\", \"Idempotency-Key\": \"76b1d337-57a7-48ee-8569-8092c87fe8a3\"}}','{\"id\": \"contact-74ce0b85\", \"ok\": true, \"operation\": \"/sms\"}',200,15,NULL,'2026-10-19 20:17:31','2026-10-19 20:17:31','2026-10-19 20:17:31'),('01a15787-5d12-7363-8c25-57d811677db1','01a15787-5802-71d6-b9f9-d7afe350c04e',1,'c3dd8fcc-7c57-4886-b35a-a773be8494b8','succeeded','{\"url\": \"http://127.0.0.1:9081/contacts/contact-source/paid\", \"body\": {\"status\": \"paid\", \"order_id\": \"source-auth-check\", \"contact_id\": \"contact-source\"}, \"method\": \"PATCH\", \"headers\": {\"Accept\": \"application/json\", \"Content-Type\": \"application/json\", \"Authorization\": \"[已隐藏]\", \"Idempotency-Key\": \"128a0e2b-6064-4f39-86a0-4c38fe04e839\"}}','{\"id\": \"contact-source\", \"ok\": true, \"operation\": \"/contacts/contact-source/paid\"}',200,3,NULL,'2026-10-19 20:17:31','2026-10-19 20:17:31','2026-10-19 20:17:31');
/*!40000 ALTER TABLE `attempts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit_entries`
--

DROP TABLE IF EXISTS `audit_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_entries` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `actor` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `action` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `subject` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `details` json NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_entries`
--

LOCK TABLES `audit_entries` WRITE;
/*!40000 ALTER TABLE `audit_entries` DISABLE KEYS */;
INSERT INTO `audit_entries` VALUES (1,'admin@localhost','workflow.save-draft','order.paid','[]','2026-10-19 10:59:00','2026-10-19 10:59:00'),(2,'system','step.dead','01a15592-72ed-7039-b4a4-b5167c78ffd5','{\"reason\": \"HTTP 400：请求被拒绝或业务结果未满足成功条件。\", \"http_status\": 400}','2026-10-19 11:10:28','2026-10-19 11:10:28'),(3,'system','step.unknown','01a15592-72f4-7201-9cd4-a6d68208d198','{\"reason\": \"HTTP 202：仅确认受理，需核对完成状态。\", \"http_status\": 202}','2026-10-19 11:10:30','2026-10-19 11:10:30'),(4,'system','demo.upgrade-supplier','demo.inventory','[]','2026-10-19 11:30:16','2026-10-19 11:30:16'),(5,'system','demo.upgrade-supplier','demo.crm','[]','2026-10-19 11:30:16','2026-10-19 11:30:16'),(6,'system','demo.upgrade-supplier','demo.sms','[]','2026-10-19 11:30:16','2026-10-19 11:30:16'),(7,'system','workflow.publish','order.paid','{\"version\": 2}','2026-10-19 11:30:16','2026-10-19 11:30:16'),(8,'admin@localhost','endpoint.save','crm.contact.paid','[]','2026-10-19 11:30:59','2026-10-19 11:30:59'),(9,'system','step.dead','01a155a5-a2bd-724e-ac12-713a05c37750','{\"reason\": \"HTTP 400：请求被拒绝或业务结果未满足成功条件。\", \"http_status\": 400}','2026-10-19 11:31:23','2026-10-19 11:31:23'),(10,'system','step.unknown','01a155a5-a2c4-71f4-988c-47dd68135084','{\"reason\": \"HTTP 202：仅确认受理，需核对完成状态。\", \"http_status\": 202}','2026-10-19 11:31:24','2026-10-19 11:31:24'),(11,'admin@localhost','provider.save','demo.crm','{\"driver\": \"demo.crm.v1\"}','2026-10-19 18:54:26','2026-10-19 18:54:26'),(12,'admin@localhost','provider.save','demo.inventory','{\"driver\": \"demo.inventory.v1\"}','2026-10-19 18:54:34','2026-10-19 18:54:34'),(13,'admin@localhost','provider.save','demo.sms','{\"driver\": \"demo.sms.v1\"}','2026-10-19 18:54:48','2026-10-19 18:54:48'),(14,'local-migration','source.rotate','shop.demo','[]','2026-10-19 20:17:01','2026-10-19 20:17:01');
/*!40000 ALTER TABLE `audit_entries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
INSERT INTO `cache` VALUES ('relay-cache-dispatch.last_tick','s:25:\"2026-10-20T04:22:46+00:00\";',1792470466),('relay-cache-illuminate:queue:restart','i:1792436274;',2107796274);
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_locks_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_locks`
--

LOCK TABLES `cache_locks` WRITE;
/*!40000 ALTER TABLE `cache_locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_locks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `delivery_tasks`
--

DROP TABLE IF EXISTS `delivery_tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery_tasks` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `event_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `key` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'waiting',
  `depends_on` json NOT NULL,
  `paused` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `delivery_tasks_event_id_key_unique` (`event_id`,`key`),
  KEY `delivery_tasks_status_index` (`status`),
  CONSTRAINT `delivery_tasks_event_id_foreign` FOREIGN KEY (`event_id`) REFERENCES `notification_events` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delivery_tasks`
--

LOCK TABLES `delivery_tasks` WRITE;
/*!40000 ALTER TABLE `delivery_tasks` DISABLE KEYS */;
INSERT INTO `delivery_tasks` VALUES ('01a15586-040a-720a-a6a3-f4ce78b687ec','01a15586-03b5-72e5-8bb8-24a1fe15321f','inventory.reserve','预留订单库存','succeeded','[]',0,'2026-10-19 10:56:48','2026-10-19 10:56:48'),('01a15586-040c-7268-9712-9d6657ae6e93','01a15586-03b5-72e5-8bb8-24a1fe15321f','crm.sync-paid','同步 CRM 付费状态','succeeded','[]',0,'2026-10-19 10:56:48','2026-10-19 10:56:49'),('01a15586-040e-70b4-9c92-6f36e0dc109b','01a15586-03b5-72e5-8bb8-24a1fe15321f','sms.confirm','发送订单确认短信','succeeded','[\"inventory.reserve\"]',0,'2026-10-19 10:56:48','2026-10-19 10:56:49'),('01a15586-0411-7060-942c-f78746788804','01a15586-03c8-70f0-b90e-9c810546d060','inventory.reserve','预留订单库存','succeeded','[]',0,'2026-10-19 10:56:48','2026-10-19 10:58:58'),('01a15586-0412-7081-ad95-4519e0094a47','01a15586-03c8-70f0-b90e-9c810546d060','crm.sync-paid','同步 CRM 付费状态','succeeded','[]',0,'2026-10-19 10:56:48','2026-10-19 10:58:49'),('01a15586-0413-70bc-ae1f-b8c8c6a8db4a','01a15586-03c8-70f0-b90e-9c810546d060','sms.confirm','发送订单确认短信','succeeded','[\"inventory.reserve\"]',0,'2026-10-19 10:56:48','2026-10-19 10:59:00'),('01a15586-0417-7217-8f18-186286a8d80e','01a15586-03ce-73d0-a067-9f3031e21e8b','inventory.reserve','预留订单库存','dead','[]',0,'2026-10-19 10:56:48','2026-10-19 10:58:49'),('01a15586-0418-7256-be9e-528e8ed1614e','01a15586-03ce-73d0-a067-9f3031e21e8b','crm.sync-paid','同步 CRM 付费状态','succeeded','[]',0,'2026-10-19 10:56:48','2026-10-19 10:58:51'),('01a15586-0419-71db-b0df-29e76ef04cbf','01a15586-03ce-73d0-a067-9f3031e21e8b','sms.confirm','发送订单确认短信','blocked','[\"inventory.reserve\"]',0,'2026-10-19 10:56:48','2026-10-19 10:58:49'),('01a15586-041b-7285-9db7-2b3bcf39ec54','01a15586-03d3-706a-8cec-ad102c0d3729','inventory.reserve','预留订单库存','unknown','[]',0,'2026-10-19 10:56:48','2026-10-19 10:58:50'),('01a15586-041c-730f-90bb-a0c3df1d6f93','01a15586-03d3-706a-8cec-ad102c0d3729','crm.sync-paid','同步 CRM 付费状态','succeeded','[]',0,'2026-10-19 10:56:48','2026-10-19 10:58:53'),('01a15586-041e-7042-9862-87d8a529b4a5','01a15586-03d3-706a-8cec-ad102c0d3729','sms.confirm','发送订单确认短信','blocked','[\"inventory.reserve\"]',0,'2026-10-19 10:56:48','2026-10-19 10:58:50'),('01a15592-72db-720d-a297-991211cf581f','01a15592-710a-72a8-8769-154ad1ecd58d','inventory.reserve','预留订单库存','succeeded','[]',0,'2026-10-19 11:10:23','2026-10-19 11:10:24'),('01a15592-72df-7137-8324-52faec78de78','01a15592-710a-72a8-8769-154ad1ecd58d','crm.sync-paid','同步 CRM 付费状态','succeeded','[]',0,'2026-10-19 11:10:23','2026-10-19 11:10:26'),('01a15592-72e2-73d9-af8b-f98dd4674d6d','01a15592-710a-72a8-8769-154ad1ecd58d','sms.confirm','发送订单确认短信','succeeded','[\"inventory.reserve\"]',0,'2026-10-19 11:10:23','2026-10-19 11:10:25'),('01a15592-72e6-729d-844b-01d3df79840d','01a15592-7117-710f-b8a2-9eba1c594fd1','inventory.reserve','预留订单库存','succeeded','[]',0,'2026-10-19 11:10:23','2026-10-19 11:10:38'),('01a15592-72e7-7224-a1ec-47f5120cea9a','01a15592-7117-710f-b8a2-9eba1c594fd1','crm.sync-paid','同步 CRM 付费状态','succeeded','[]',0,'2026-10-19 11:10:23','2026-10-19 11:10:30'),('01a15592-72ea-70e1-a607-9c3e90c7bcd7','01a15592-7117-710f-b8a2-9eba1c594fd1','sms.confirm','发送订单确认短信','succeeded','[\"inventory.reserve\"]',0,'2026-10-19 11:10:23','2026-10-19 11:10:39'),('01a15592-72ed-7039-b4a4-b5167c02d005','01a15592-711f-72a7-95cd-b491b31d6ba2','inventory.reserve','预留订单库存','dead','[]',0,'2026-10-19 11:10:23','2026-10-19 11:10:28'),('01a15592-72ee-721c-ad1f-907e6e4db95c','01a15592-711f-72a7-95cd-b491b31d6ba2','crm.sync-paid','同步 CRM 付费状态','succeeded','[]',0,'2026-10-19 11:10:23','2026-10-19 11:10:34'),('01a15592-72f0-71ae-a539-9587b6d07dd6','01a15592-711f-72a7-95cd-b491b31d6ba2','sms.confirm','发送订单确认短信','blocked','[\"inventory.reserve\"]',0,'2026-10-19 11:10:23','2026-10-19 11:10:28'),('01a15592-72f3-7268-92e7-207da2e96ec7','01a15592-7127-7014-a1eb-30740c6e1060','inventory.reserve','预留订单库存','unknown','[]',0,'2026-10-19 11:10:23','2026-10-19 11:10:30'),('01a15592-72f4-7201-9cd4-a6d682c6e711','01a15592-7127-7014-a1eb-30740c6e1060','crm.sync-paid','同步 CRM 付费状态','succeeded','[]',0,'2026-10-19 11:10:23','2026-10-19 11:10:38'),('01a15592-72f6-7234-9679-7c600b6d893f','01a15592-7127-7014-a1eb-30740c6e1060','sms.confirm','发送订单确认短信','blocked','[\"inventory.reserve\"]',0,'2026-10-19 11:10:23','2026-10-19 11:10:30'),('01a155a5-a2a8-7390-8af1-921c6173b6a6','01a155a5-a03d-70c9-b9b7-08516c8925ae','inventory.reserve','预留订单库存','succeeded','[]',0,'2026-10-19 11:31:20','2026-10-19 11:31:21'),('01a155a5-a2af-7280-8ba9-bef08814f2d4','01a155a5-a03d-70c9-b9b7-08516c8925ae','crm.sync-paid','同步 CRM 付费状态','succeeded','[]',0,'2026-10-19 11:31:20','2026-10-19 11:31:22'),('01a155a5-a2b1-7244-9521-1a82487e76fa','01a155a5-a03d-70c9-b9b7-08516c8925ae','sms.confirm','发送订单确认短信','succeeded','[\"inventory.reserve\"]',0,'2026-10-19 11:31:20','2026-10-19 11:31:22'),('01a155a5-a2b5-726c-ac1c-41f500f7a3ef','01a155a5-a046-715a-b53f-89198179f3a0','inventory.reserve','预留订单库存','succeeded','[]',0,'2026-10-19 11:31:20','2026-10-19 11:31:35'),('01a155a5-a2b7-73c5-b4eb-d572c4b8d0e8','01a155a5-a046-715a-b53f-89198179f3a0','crm.sync-paid','同步 CRM 付费状态','succeeded','[]',0,'2026-10-19 11:31:20','2026-10-19 11:31:24'),('01a155a5-a2b9-7075-be94-2292a6304e83','01a155a5-a046-715a-b53f-89198179f3a0','sms.confirm','发送订单确认短信','succeeded','[\"inventory.reserve\"]',0,'2026-10-19 11:31:20','2026-10-19 11:31:36'),('01a155a5-a2bd-724e-ac12-713a056c455a','01a155a5-a04d-7090-b4df-23121657bde5','inventory.reserve','预留订单库存','dead','[]',0,'2026-10-19 11:31:20','2026-10-19 11:31:23'),('01a155a5-a2be-7361-a1bf-cf6bf66f354b','01a155a5-a04d-7090-b4df-23121657bde5','crm.sync-paid','同步 CRM 付费状态','succeeded','[]',0,'2026-10-19 11:31:20','2026-10-19 11:31:26'),('01a155a5-a2c0-7230-bdef-7b61aee41186','01a155a5-a04d-7090-b4df-23121657bde5','sms.confirm','发送订单确认短信','blocked','[\"inventory.reserve\"]',0,'2026-10-19 11:31:20','2026-10-19 11:31:23'),('01a155a5-a2c3-70ff-9910-749471e224f0','01a155a5-a053-7202-b8ae-2ef3b2e14507','inventory.reserve','预留订单库存','unknown','[]',0,'2026-10-19 11:31:20','2026-10-19 11:31:24'),('01a155a5-a2c5-713d-b37d-8f4ace3da070','01a155a5-a053-7202-b8ae-2ef3b2e14507','crm.sync-paid','同步 CRM 付费状态','succeeded','[]',0,'2026-10-19 11:31:20','2026-10-19 11:31:28'),('01a155a5-a2c6-723c-9be1-3cc7efe3a766','01a155a5-a053-7202-b8ae-2ef3b2e14507','sms.confirm','发送订单确认短信','blocked','[\"inventory.reserve\"]',0,'2026-10-19 11:31:20','2026-10-19 11:31:24'),('01a15778-5f08-73ce-9d3a-9447ae9eaaf8','01a15778-5e1e-73a1-aa1b-ce13ee386500','inventory.reserve','预留订单库存','succeeded','[]',0,'2026-10-19 20:01:08','2026-10-19 20:01:09'),('01a15778-5f0c-703f-97df-1f8df8a6311d','01a15778-5e1e-73a1-aa1b-ce13ee386500','crm.sync-paid','同步 CRM 付费状态','succeeded','[]',0,'2026-10-19 20:01:08','2026-10-19 20:01:11'),('01a15778-5f0f-7233-8ec6-59408b08fe70','01a15778-5e1e-73a1-aa1b-ce13ee386500','sms.confirm','发送订单确认短信','succeeded','[\"inventory.reserve\"]',0,'2026-10-19 20:01:08','2026-10-19 20:01:10'),('01a15787-57f8-72d6-aa24-5acf365d5f28','01a15787-556d-739f-b221-349fc6283c7b','inventory.reserve','预留订单库存','succeeded','[]',0,'2026-10-19 20:17:30','2026-10-19 20:17:30'),('01a15787-57ff-7397-947f-b715441261ac','01a15787-556d-739f-b221-349fc6283c7b','crm.sync-paid','同步 CRM 付费状态','succeeded','[]',0,'2026-10-19 20:17:30','2026-10-19 20:17:31'),('01a15787-5803-7109-a939-323fa94014d5','01a15787-556d-739f-b221-349fc6283c7b','sms.confirm','发送订单确认短信','succeeded','[\"inventory.reserve\"]',0,'2026-10-19 20:17:30','2026-10-19 20:17:31');
/*!40000 ALTER TABLE `delivery_tasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `endpoints`
--

DROP TABLE IF EXISTS `endpoints`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `endpoints` (
  `id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `provider_id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `operation` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `method` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `path` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` json NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `endpoints_provider_id_foreign` (`provider_id`),
  CONSTRAINT `endpoints_provider_id_foreign` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `endpoints`
--

LOCK TABLES `endpoints` WRITE;
/*!40000 ALTER TABLE `endpoints` DISABLE KEYS */;
INSERT INTO `endpoints` VALUES ('crm.contact.create','demo.crm','contact.create','创建联系人','POST','/contacts','{\"timeout\": 10, \"idempotent\": true}',1,'2026-10-19 10:56:38','2026-10-19 11:30:16'),('crm.contact.paid','demo.crm','contact.mark-paid','更新付费状态','PATCH','/contacts/{contact_id}/paid','{\"timeout\": 10, \"idempotent\": true}',1,'2026-10-19 10:56:38','2026-10-19 11:30:16'),('inventory.reserve','demo.inventory','stock.reserve','预留库存','POST','/reserve','{\"timeout\": 10, \"idempotent\": true}',1,'2026-10-19 10:56:38','2026-10-19 11:30:16'),('sms.order.confirm','demo.sms','order.confirm','发送订单确认短信','POST','/sms','{\"timeout\": 10, \"idempotent\": true}',1,'2026-10-19 10:56:38','2026-10-19 11:30:16');
/*!40000 ALTER TABLE `endpoints` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `event_sources`
--

DROP TABLE IF EXISTS `event_sources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `event_sources` (
  `id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token_hash` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT '0',
  `token_issued_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `event_sources_token_hash_unique` (`token_hash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event_sources`
--

LOCK TABLES `event_sources` WRITE;
/*!40000 ALTER TABLE `event_sources` DISABLE KEYS */;
INSERT INTO `event_sources` VALUES ('local-verification','local-verification',NULL,0,NULL,'2026-10-19 20:17:01','2026-10-19 20:17:01'),('shop.demo','商城演示系统','f11f75644c07e1485c4c2c59d834420ef276961cadb9955d3923207ecdf47738',1,'2026-10-19 20:17:01','2026-10-19 20:17:01','2026-10-19 20:17:01');
/*!40000 ALTER TABLE `event_sources` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `event_streams`
--

DROP TABLE IF EXISTS `event_streams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `event_streams` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `source` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `lock_key` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `event_streams_source_business_key_unique` (`source`,`lock_key`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event_streams`
--

LOCK TABLES `event_streams` WRITE;
/*!40000 ALTER TABLE `event_streams` DISABLE KEYS */;
INSERT INTO `event_streams` VALUES (6,'__relay_capacity__','__capacity__'),(21,'local-verification','__source_lock__'),(5,'shop.demo','__source_lock__'),(3,'shop.demo','demo-dead'),(2,'shop.demo','demo-retry'),(1,'shop.demo','demo-success'),(4,'shop.demo','demo-unknown');
/*!40000 ALTER TABLE `event_streams` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `failed_jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_batches` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_batches`
--

LOCK TABLES `job_batches` WRITE;
/*!40000 ALTER TABLE `job_batches` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint unsigned NOT NULL,
  `reserved_at` int unsigned DEFAULT NULL,
  `available_at` int unsigned NOT NULL,
  `created_at` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'0001_01_01_000000_create_users_table',1),(2,'0001_01_01_000001_create_cache_table',1),(3,'0001_01_01_000002_create_jobs_table',1),(4,'2026_10_20_000001_create_dispatch_tables',1),(5,'2026_10_20_000002_add_supplier_operation_to_endpoints',2),(6,'2026_10_20_000003_add_occurred_at_to_notification_events',3),(7,'2026_10_20_000004_add_event_sources',4);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_events`
--

DROP TABLE IF EXISTS `notification_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_events` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `external_id` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `source` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `predecessor_id` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `payload` json NOT NULL,
  `fingerprint` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `version_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `conversion_status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `conversion_error` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `occurred_at` datetime(6) DEFAULT NULL,
  `fingerprint_version` tinyint unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `notification_events_source_external_id_unique` (`source`,`external_id`),
  KEY `notification_events_version_id_foreign` (`version_id`),
  KEY `notification_events_conversion_status_index` (`conversion_status`),
  CONSTRAINT `notification_events_version_id_foreign` FOREIGN KEY (`version_id`) REFERENCES `workflow_versions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_events`
--

LOCK TABLES `notification_events` WRITE;
/*!40000 ALTER TABLE `notification_events` DISABLE KEYS */;
INSERT INTO `notification_events` VALUES ('01a15586-03b5-72e5-8bb8-24a1fe15321f','demo-success-185648','shop.demo','order.paid.v1',NULL,'{\"order_id\": \"demo-success\", \"contact_id\": \"contact-demo\"}','2fde3421cb028602b242fd24f64852386ef49b512d6084b96dddef7c66a574b2','01a15585-dd6b-7170-8bb2-e9a43fd12a3c','converted',NULL,'2026-10-19 10:56:48','2026-10-19 10:56:48',NULL,1),('01a15586-03c8-70f0-b90e-9c810546d060','demo-retry-185648','shop.demo','order.paid.v1',NULL,'{\"order_id\": \"demo-retry\", \"contact_id\": \"contact-demo\"}','7f950976097f19bb5785e16dd527deaabbb282a9dd0949a077e33c6c3abc5460','01a15585-dd6b-7170-8bb2-e9a43fd12a3c','converted',NULL,'2026-10-19 10:56:48','2026-10-19 10:56:48',NULL,1),('01a15586-03ce-73d0-a067-9f3031e21e8b','demo-dead-185648','shop.demo','order.paid.v1',NULL,'{\"order_id\": \"demo-dead\", \"contact_id\": \"contact-demo\"}','4e2708aeeb53f484488daedaae5ca265d30ffcaa2679844904790ab7096cc0c3','01a15585-dd6b-7170-8bb2-e9a43fd12a3c','converted',NULL,'2026-10-19 10:56:48','2026-10-19 10:56:48',NULL,1),('01a15586-03d3-706a-8cec-ad102c0d3729','demo-unknown-185648','shop.demo','order.paid.v1',NULL,'{\"order_id\": \"demo-unknown\", \"contact_id\": \"contact-demo\"}','47af8e83c8523248415ee3d9100f7a57eccf3f2470b938eba6e065eeb2cddd88','01a15585-dd6b-7170-8bb2-e9a43fd12a3c','converted',NULL,'2026-10-19 10:56:48','2026-10-19 10:56:48',NULL,1),('01a15592-710a-72a8-8769-154ad1ecd58d','demo-success-191022','shop.demo','order.paid.v1',NULL,'{\"order_id\": \"demo-success\", \"contact_id\": \"contact-demo\"}','06f4893cc5c6bf001df40b870251e1b126d61877c8535a5f90c6e0c8785aaf33','01a15585-dd6b-7170-8bb2-e9a43fd12a3c','converted',NULL,'2026-10-19 11:10:22','2026-10-19 11:10:23',NULL,1),('01a15592-7117-710f-b8a2-9eba1c594fd1','demo-retry-191022','shop.demo','order.paid.v1',NULL,'{\"order_id\": \"demo-retry\", \"contact_id\": \"contact-demo\"}','6f0fbab507cd7b571564c3b420c26cff8e677b08152eaed2f5b7821e6e7d7478','01a15585-dd6b-7170-8bb2-e9a43fd12a3c','converted',NULL,'2026-10-19 11:10:22','2026-10-19 11:10:23',NULL,1),('01a15592-711f-72a7-95cd-b491b31d6ba2','demo-dead-191023','shop.demo','order.paid.v1',NULL,'{\"order_id\": \"demo-dead\", \"contact_id\": \"contact-demo\"}','ba7943a6e792706c00382c62fc20a14385e703c689ccb79fd360cb319e237822','01a15585-dd6b-7170-8bb2-e9a43fd12a3c','converted',NULL,'2026-10-19 11:10:23','2026-10-19 11:10:23',NULL,1),('01a15592-7127-7014-a1eb-30740c6e1060','demo-unknown-191023','shop.demo','order.paid.v1',NULL,'{\"order_id\": \"demo-unknown\", \"contact_id\": \"contact-demo\"}','6edafebe581fc1716975f9b5aef30eda07922cbd83518c10eb71bbe074e06221','01a15585-dd6b-7170-8bb2-e9a43fd12a3c','converted',NULL,'2026-10-19 11:10:23','2026-10-19 11:10:23',NULL,1),('01a155a5-a03d-70c9-b9b7-08516c8925ae','demo-success-193120','shop.demo','order.paid.v1',NULL,'{\"order_id\": \"demo-success\", \"contact_id\": \"contact-demo\"}','345b0b3a3ba1c78c2fb23bf73ca787bea90143084e9410a4edee8a46042fa8fb','01a155a4-a7a6-721e-a2f4-325c4454c429','converted',NULL,'2026-10-19 11:31:20','2026-10-19 11:31:20',NULL,1),('01a155a5-a046-715a-b53f-89198179f3a0','demo-retry-193120','shop.demo','order.paid.v1',NULL,'{\"order_id\": \"demo-retry\", \"contact_id\": \"contact-demo\"}','b9b3dda6c9a5312ffb2b7168ada110d7ebe495731780cc2bb028746fb0c37c5c','01a155a4-a7a6-721e-a2f4-325c4454c429','converted',NULL,'2026-10-19 11:31:20','2026-10-19 11:31:20',NULL,1),('01a155a5-a04d-7090-b4df-23121657bde5','demo-dead-193120','shop.demo','order.paid.v1',NULL,'{\"order_id\": \"demo-dead\", \"contact_id\": \"contact-demo\"}','17891611a7dc5f310a082bbd371e6e8117d90263152f1734118f40b4bd6fe668','01a155a4-a7a6-721e-a2f4-325c4454c429','converted',NULL,'2026-10-19 11:31:20','2026-10-19 11:31:20',NULL,1),('01a155a5-a053-7202-b8ae-2ef3b2e14507','demo-unknown-193120','shop.demo','order.paid.v1',NULL,'{\"order_id\": \"demo-unknown\", \"contact_id\": \"contact-demo\"}','03f2b3d0e7852aee63ad55dd35b0c802df81e520583670e93a6786d87a5c6859','01a155a4-a7a6-721e-a2f4-325c4454c429','converted',NULL,'2026-10-19 11:31:20','2026-10-19 11:31:20',NULL,1),('01a15778-5e1e-73a1-aa1b-ce13ee386500','timestamp-check-c17d6498-77ae-43a3-9184-3d149b2dc059','local-verification','order.paid.v1',NULL,'{\"order_id\": \"timestamp-check\", \"contact_id\": \"timestamp-contact\"}','f2e1082ddf6b6c20482a03591728ba9aa0241a80e21f6e08d2aa1c8d4594ef8d','01a155a4-a7a6-721e-a2f4-325c4454c429','converted',NULL,'2026-10-19 20:01:09','2026-10-19 20:01:08','2026-10-19 01:30:00.123456',1),('01a15787-556d-739f-b221-349fc6283c7b','source-auth-e66c0948-2141-4cbc-9a6e-691976f06a0d','shop.demo','order.paid.v1',NULL,'{\"order_id\": \"source-auth-check\", \"contact_id\": \"contact-source\"}','a581738cd07814f8e59c04570d642712b709c60eaae7c0361be99cd25cbcd130','01a155a4-a7a6-721e-a2f4-325c4454c429','converted',NULL,'2026-10-19 20:17:29','2026-10-19 20:17:30','2026-10-20 04:17:29.000000',2);
/*!40000 ALTER TABLE `notification_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `providers`
--

DROP TABLE IF EXISTS `providers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `providers` (
  `id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `driver` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `base_url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `credentials` text COLLATE utf8mb4_unicode_ci,
  `settings` json NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT '1',
  `failure_streak` int unsigned NOT NULL DEFAULT '0',
  `circuit_until` timestamp NULL DEFAULT NULL,
  `busy_token` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `busy_until` timestamp NULL DEFAULT NULL,
  `next_request_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `providers`
--

LOCK TABLES `providers` WRITE;
/*!40000 ALTER TABLE `providers` DISABLE KEYS */;
INSERT INTO `providers` VALUES ('demo.crm','CRM 系统','demo.crm.v1','http://127.0.0.1:9081','eyJpdiI6IkFtRFl1eDNMOFlLU3B6R1VpbStrU3c9PSIsInZhbHVlIjoickxyMWV0eTFKY0orNzdsQWlRWmxKenR5dmFWWHZ0NjhnVTV0Y3QzYUREZ3pFY2x3Q3FJZnhtNEpLVnRBbWk4eiIsIm1hYyI6IjNkNmJmOThlYjg0YjdjMTdhNzBhODEzMDZkOWNlYzViYWRkMzEyNGNmMmQ3YWJjYTE1ODhjMjI0ODYwZTMxNWQiLCJ0YWciOiIifQ==','{\"interval_ms\": 100, \"circuit_seconds\": 60, \"circuit_threshold\": 5}',1,0,NULL,NULL,NULL,'2026-10-19 20:17:32','2026-10-19 10:56:38','2026-10-19 20:17:31'),('demo.inventory','库存系统','demo.inventory.v1','http://127.0.0.1:9081','eyJpdiI6InJvVFJXdXdtM1ROUDFNVld2UXhVNEE9PSIsInZhbHVlIjoiUTN5QUxpRUk4cCtwSXVINHFrOFVJTm1ld0oyOFRlYmI1RG9GTmQ4TWlaQmpUQmI0QVJteXZMTzlWbVdZUnUzbW00Y0QvYXlzQWpWNXNhU1NIZUVUQWc9PSIsIm1hYyI6ImYzMGJlZDlmZTk4ZThmZmIxMzk3MzBkZmJmOThhY2YzZjU2ZDVjYzc0NTU5YjMxZTZiYzc4NjUwMDQ0NDg3M2MiLCJ0YWciOiIifQ==','{\"interval_ms\": 100, \"circuit_seconds\": 60, \"circuit_threshold\": 5}',1,0,NULL,NULL,NULL,'2026-10-19 20:17:31','2026-10-19 10:56:38','2026-10-19 20:17:30'),('demo.sms','短信服务','demo.sms.v1','http://127.0.0.1:9081','eyJpdiI6IjJKVFdQMVdXVXJ4QUNXeWs4eDFrTmc9PSIsInZhbHVlIjoiYUFXU3JucTBMajlhOUorWFFxOHdmZ25kK3h6UXQwdGdQeEFBR3U5dmV4am9mOEw0QXY1RUYzUW5wRVFoTVpMeSIsIm1hYyI6IjRhYjRiNDNjMDY5NjJmYWIwNzY3YWU2ZDUxYmZjOGYyOGQwOGZiYzFjOGYzZDkwMzUzMGYxYWU2MGFjNzIyYTYiLCJ0YWciOiIifQ==','{\"interval_ms\": 100, \"circuit_seconds\": 60, \"circuit_threshold\": 5}',1,0,NULL,NULL,NULL,'2026-10-19 20:17:32','2026-10-19 10:56:38','2026-10-19 20:17:31');
/*!40000 ALTER TABLE `providers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `request_steps`
--

DROP TABLE IF EXISTS `request_steps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `request_steps` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `task_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `key` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `provider_id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `endpoint_snapshot` json NOT NULL,
  `input_mapping` json NOT NULL,
  `depends_on` json NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'waiting',
  `attempt_count` int unsigned NOT NULL DEFAULT '0',
  `cycle_attempts` int unsigned NOT NULL DEFAULT '0',
  `max_attempts` int unsigned NOT NULL DEFAULT '5',
  `available_at` timestamp NOT NULL,
  `expires_at` timestamp NOT NULL,
  `enqueued_until` timestamp NULL DEFAULT NULL,
  `lease_token` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lease_until` timestamp NULL DEFAULT NULL,
  `idempotency_key` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_error` text COLLATE utf8mb4_unicode_ci,
  `output` longtext COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `request_steps_task_id_key_unique` (`task_id`,`key`),
  UNIQUE KEY `request_steps_idempotency_key_unique` (`idempotency_key`),
  KEY `request_steps_provider_id_foreign` (`provider_id`),
  KEY `request_steps_status_available_at_index` (`status`,`available_at`),
  KEY `request_steps_status_lease_until_index` (`status`,`lease_until`),
  CONSTRAINT `request_steps_provider_id_foreign` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`id`),
  CONSTRAINT `request_steps_task_id_foreign` FOREIGN KEY (`task_id`) REFERENCES `delivery_tasks` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `request_steps`
--

LOCK TABLES `request_steps` WRITE;
/*!40000 ALTER TABLE `request_steps` DISABLE KEYS */;
INSERT INTO `request_steps` VALUES ('01a15586-040c-7268-9712-9d665743ae25','01a15586-040a-720a-a6a3-f4ce78b687ec','reserve','预留库存','demo.inventory','{\"id\": \"inventory.reserve\", \"name\": \"预留库存\", \"path\": \"/reserve\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.inventory\"}','{\"order_id\": \"$event.payload.order_id\"}','[]','succeeded',1,1,5,'2026-10-19 10:56:48','2026-10-20 10:56:48',NULL,NULL,NULL,'238ef269-765e-4662-ac8a-47cefc5c7791',NULL,'eyJpdiI6IjQ0cmZDTWU1Q2xSeFhJUFlKbXVoSUE9PSIsInZhbHVlIjoiQmlpamdCQ2w1d0psalpoR0doK0dzbFBmMXRwZ2JhL3ZVdVFvS09FaGl2b2JWenZybHA5a0RHdVQvVlhWdjlpeVBuZWRweFhqTGY2b0VDSWI5RW5ObkE9PSIsIm1hYyI6IjE0NmViZTdlNDIyMjdiYjg5YmU2ZWQ5Yjg3NTRlMWI1MjdhMzk5NTcyYTQ5NTE0MDVkNjk5MzMxMWJmZjViYTgiLCJ0YWciOiIifQ==','2026-10-19 10:56:48','2026-10-19 10:56:48'),('01a15586-040d-7014-8bf1-bfd5bc2084e4','01a15586-040c-7268-9712-9d6657ae6e93','create','创建联系人','demo.crm','{\"id\": \"crm.contact.create\", \"name\": \"创建联系人\", \"path\": \"/contacts\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.crm\"}','{\"contact_id\": \"$event.payload.contact_id\"}','[]','succeeded',1,1,5,'2026-10-19 10:56:48','2026-10-20 10:56:48',NULL,NULL,NULL,'0e732506-1a5c-4170-bbb9-9c8c96f84b87',NULL,'eyJpdiI6IkxncGU2Mk13eU5VZmp1WElBaXBEUUE9PSIsInZhbHVlIjoiK3VwaGFXMVZRTjBGeVpxVFI1YXJaa1pJeEU2ZTJIdnlLQU1ueW1DZmVLYnJXZW10UCtLdXVWeFhTU3RTTjEvZVhmaDV1TzFPTTBRa3VQRGNIYTRvWXc9PSIsIm1hYyI6IjkwNDRmMzIxODhjMGYxMzE3ZmI0MGZjZjg4ZThhMGZmMjhmZjgzMGJhNzE5YzU5MDVjNzI3MjcwNWJlNjgyZTYiLCJ0YWciOiIifQ==','2026-10-19 10:56:48','2026-10-19 10:56:48'),('01a15586-040e-70b4-9c92-6f36e04af4d3','01a15586-040c-7268-9712-9d6657ae6e93','mark-paid','更新付费状态','demo.crm','{\"id\": \"crm.contact.paid\", \"name\": \"更新付费状态\", \"path\": \"/paid\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.crm\"}','{\"order_id\": \"$event.payload.order_id\", \"contact_id\": \"$steps.create.output.id\"}','[\"create\"]','succeeded',1,1,5,'2026-10-19 10:56:48','2026-10-20 10:56:48',NULL,NULL,NULL,'d5a669d4-cb40-4487-a835-9edda9bde777',NULL,'eyJpdiI6ImpGclpndmFua3E1QW15dlAySVFRSFE9PSIsInZhbHVlIjoiaUo5TVJvdVFtZjZIUkpSWmc5MklNZlRRcnJ4TVhEeVBmQnphU3oyWVl1SlpyV2g5TS83ckZPRkJqbFQ4SUlzQ2R5ZEI1SU82SHBpMVpLRUprcTJuRWc9PSIsIm1hYyI6ImRmYjFiYWM0YWJmMDZhZWNiODQ2ZmYxZDM1MDNmODdjM2I0NTcxYTMyMmU2Y2E5ZjYxMThkNGUyM2I5N2ExMzIiLCJ0YWciOiIifQ==','2026-10-19 10:56:48','2026-10-19 10:56:49'),('01a15586-040f-700d-99be-dc05890c844e','01a15586-040e-70b4-9c92-6f36e0dc109b','send','发送短信','demo.sms','{\"id\": \"sms.order.confirm\", \"name\": \"发送订单确认短信\", \"path\": \"/sms\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.sms\"}','{\"order_id\": \"$event.payload.order_id\"}','[]','succeeded',1,1,5,'2026-10-19 10:56:48','2026-10-20 10:56:48',NULL,NULL,NULL,'e7796de3-67d1-40b2-9968-3352bcae2515',NULL,'eyJpdiI6Ik42dFA2OXRFbmZQUGxTeThlMG5HdHc9PSIsInZhbHVlIjoiWFVNSTVQTVVHT3ptUDJseFZzci9Hc1NoQzM5MThtOHFXSUVINE0ybkNPUzNVUWpiRmhQeXRid0lDSHJ0Rk1hcGdzeWRtWUJ4ZzN5a0xkenZjV2dZSlE9PSIsIm1hYyI6IjAyNGU1YjVkNjM3ZjI0ODQxZDVhZGU5ZTdkOTk0YzYxN2QxNzljZTM3ZThmMTA0MTUyYTI2YmNhYWJlYTFmZWYiLCJ0YWciOiIifQ==','2026-10-19 10:56:48','2026-10-19 10:56:49'),('01a15586-0411-7060-942c-f78746804f00','01a15586-0411-7060-942c-f78746788804','reserve','预留库存','demo.inventory','{\"id\": \"inventory.reserve\", \"name\": \"预留库存\", \"path\": \"/reserve\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.inventory\"}','{\"order_id\": \"$event.payload.order_id\"}','[]','succeeded',2,2,5,'2026-10-19 10:58:58','2026-10-20 10:56:48',NULL,NULL,NULL,'c9a3a58b-0eb4-46e2-adf8-449442f6632d',NULL,'eyJpdiI6IjRnRzNuS2hTT0kyU09KMmRwZmRYZ2c9PSIsInZhbHVlIjoidHp3ZU0yYTljYTJqcWtSUnVLdXlWYTlBVjJtMVlnRC9hLzhIRWoxaWF1VDl4Q2RSVEJlV1FBWWJiOFQyMHF1ZDltQlE4UWJWNzI1bkpRQ2h4VmZXN2c9PSIsIm1hYyI6ImFkZDY3NzNiYmZmMTAxYmE2MDY2MDlmMGEyZDY2MjdjMzNkYWZhZGU4MDkxZjA4MGZhZmE0YTRhNzQwZjZmOTkiLCJ0YWciOiIifQ==','2026-10-19 10:56:48','2026-10-19 10:58:58'),('01a15586-0412-7081-ad95-4519e0219923','01a15586-0412-7081-ad95-4519e0094a47','create','创建联系人','demo.crm','{\"id\": \"crm.contact.create\", \"name\": \"创建联系人\", \"path\": \"/contacts\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.crm\"}','{\"contact_id\": \"$event.payload.contact_id\"}','[]','succeeded',1,1,5,'2026-10-19 10:56:48','2026-10-20 10:56:48',NULL,NULL,NULL,'23baf2df-835a-48f6-b18e-9019ed12049a',NULL,'eyJpdiI6IjB0VTQzZloyQm5ZdEFCQy85alVyT1E9PSIsInZhbHVlIjoiK0gvdmIzU2ZZRjFlcktrRGkvYm8rcG9LeE1KbHBXUExGbGkrNlVRVjNxSjhKUUdaNW43THdBYW5FYlRWZ3F6U25iVFJkdlhGQnFuazRHUVJuV2I2TWc9PSIsIm1hYyI6ImNmZDUwMmY3MGI2MGYwMjRjNGRlNmI5M2UwNDFlNDJlYWRiNjdhOTJlNzFiMjVkY2JjZGVkODQ2ZDUzNDliYWEiLCJ0YWciOiIifQ==','2026-10-19 10:56:48','2026-10-19 10:58:48'),('01a15586-0413-70bc-ae1f-b8c8c6577b8a','01a15586-0412-7081-ad95-4519e0094a47','mark-paid','更新付费状态','demo.crm','{\"id\": \"crm.contact.paid\", \"name\": \"更新付费状态\", \"path\": \"/paid\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.crm\"}','{\"order_id\": \"$event.payload.order_id\", \"contact_id\": \"$steps.create.output.id\"}','[\"create\"]','succeeded',1,1,5,'2026-10-19 10:56:48','2026-10-20 10:56:48',NULL,NULL,NULL,'1bbf8c70-b1b8-4d00-a844-46586659cc9f',NULL,'eyJpdiI6InlObVg3dTJDcTEwUWVLS25yME9OVFE9PSIsInZhbHVlIjoibkFvWThZVzN1YStxOVpONnFsVVdlOVM3VWhZTTRDYkdmYksyN1FlYkhPN01OQ1BWMk1LWXZFUTZKZHl1enF0WW5waDlIRTR2bU9XTkY2R2RHMjVCQ3c9PSIsIm1hYyI6Ijk5ZGJlODAxOWI1ZmQ5MGEwYjc1N2NlMjQzMThhMTAzZjc1MTRhMmYyYWM4MTdkNjZlMjRhN2U1OTE2ZjJkZjUiLCJ0YWciOiIifQ==','2026-10-19 10:56:48','2026-10-19 10:58:49'),('01a15586-0414-72ff-9972-3e45ced5fdcf','01a15586-0413-70bc-ae1f-b8c8c6a8db4a','send','发送短信','demo.sms','{\"id\": \"sms.order.confirm\", \"name\": \"发送订单确认短信\", \"path\": \"/sms\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.sms\"}','{\"order_id\": \"$event.payload.order_id\"}','[]','succeeded',1,1,5,'2026-10-19 10:56:48','2026-10-20 10:56:48',NULL,NULL,NULL,'6e3eefb1-0dc2-4503-b61d-2912a62b9067',NULL,'eyJpdiI6ImwwMmxuMjZqdXJTMjdaYS9QOUpWdnc9PSIsInZhbHVlIjoiVGRYd1ZHdWRDUEJNUlFzOUkvWDNXdDR2dlR6VklwM3hDRHJWTGtSNWFJZjI2eTAydXErSmpPcnp5Tm9kRjFhcDR5cVcxUkViRTdDR0ZGZnR6T05FUmc9PSIsIm1hYyI6IjBiZGM2NGMwMGIzYjJhMzgyYjk0NTJlNDY5OGE0MzVjN2VjM2Y0Yjg1NjVkOGRkYTA3OTZiMTU2MGE2Mjc5ODgiLCJ0YWciOiIifQ==','2026-10-19 10:56:48','2026-10-19 10:59:00'),('01a15586-0417-7217-8f18-186286e7ba15','01a15586-0417-7217-8f18-186286a8d80e','reserve','预留库存','demo.inventory','{\"id\": \"inventory.reserve\", \"name\": \"预留库存\", \"path\": \"/reserve\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.inventory\"}','{\"order_id\": \"$event.payload.order_id\"}','[]','dead',1,1,5,'2026-10-19 10:56:48','2026-10-20 10:56:48',NULL,NULL,NULL,'3b48ff23-2f2f-43ad-a49c-a0c6d7ce9bff','HTTP 400：请求被拒绝或业务结果未满足成功条件。',NULL,'2026-10-19 10:56:48','2026-10-19 10:58:49'),('01a15586-0418-7256-be9e-528e8f4b540b','01a15586-0418-7256-be9e-528e8ed1614e','create','创建联系人','demo.crm','{\"id\": \"crm.contact.create\", \"name\": \"创建联系人\", \"path\": \"/contacts\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.crm\"}','{\"contact_id\": \"$event.payload.contact_id\"}','[]','succeeded',1,1,5,'2026-10-19 10:56:48','2026-10-20 10:56:48',NULL,NULL,NULL,'06305f72-936b-4fec-af66-666d89cb7781',NULL,'eyJpdiI6Im5yMTI3MVRmekUzV0dHOGxKTXJ2clE9PSIsInZhbHVlIjoiU0lKNUdMdnM1RzhyNTNBUVUzZmxmQVNKa0ZvTWRaWmNFUXZpdFBXUDMrUU52WnFCMHBLb2dDTksxWHVrY2ZkRVVFQ2IzeWdTaUxOZHFZRDBCOEpHQ1E9PSIsIm1hYyI6ImJiNGFiMDcxZWE4YjRmODEzMzNlYTE1OGIwNWMwMjIxZTk1MGY3Yzc0ZWNkYmI5ZTM2NTAwMTMyZjg0NGNjNDciLCJ0YWciOiIifQ==','2026-10-19 10:56:48','2026-10-19 10:58:50'),('01a15586-0419-71db-b0df-29e76e88f71b','01a15586-0418-7256-be9e-528e8ed1614e','mark-paid','更新付费状态','demo.crm','{\"id\": \"crm.contact.paid\", \"name\": \"更新付费状态\", \"path\": \"/paid\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.crm\"}','{\"order_id\": \"$event.payload.order_id\", \"contact_id\": \"$steps.create.output.id\"}','[\"create\"]','succeeded',1,1,5,'2026-10-19 10:56:48','2026-10-20 10:56:48',NULL,NULL,NULL,'c5bf219d-3318-4a75-a033-0dd40cdf7a3c',NULL,'eyJpdiI6ImlkYXhhNS9jVndUYzJDQWl0T0FNVnc9PSIsInZhbHVlIjoiZTdQenBNSWRTNkczYWFTVUNQNHIyeThPVXl0QjV3ZFNub0J1aEY1c2VXVEhZRlBSZUhUQk1zTHBpbW4yOUltYUxlSXd5YkVRTGdJVGhWaDg2dXI5VUE9PSIsIm1hYyI6IjI1ZTNhMDFmNjA0YmVmODlkYTkxNjMzZGU1MTU4M2UzMTgzOGRlMzFhNjM1ZWEyMjA3ZWMxMTU5ZjI3ZDY2MzQiLCJ0YWciOiIifQ==','2026-10-19 10:56:48','2026-10-19 10:58:51'),('01a15586-041a-719e-a9d5-affffa932746','01a15586-0419-71db-b0df-29e76ef04cbf','send','发送短信','demo.sms','{\"id\": \"sms.order.confirm\", \"name\": \"发送订单确认短信\", \"path\": \"/sms\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.sms\"}','{\"order_id\": \"$event.payload.order_id\"}','[]','blocked',0,0,5,'2026-10-19 10:56:48','2026-10-20 10:56:48',NULL,NULL,NULL,'df669f62-6f6d-41ed-9cd1-87cbe295fc7c',NULL,NULL,'2026-10-19 10:56:48','2026-10-19 10:58:49'),('01a15586-041c-730f-90bb-a0c3de409b5e','01a15586-041b-7285-9db7-2b3bcf39ec54','reserve','预留库存','demo.inventory','{\"id\": \"inventory.reserve\", \"name\": \"预留库存\", \"path\": \"/reserve\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.inventory\"}','{\"order_id\": \"$event.payload.order_id\"}','[]','unknown',1,1,5,'2026-10-19 10:56:48','2026-10-20 10:56:48',NULL,NULL,NULL,'dc733340-a5c7-4b67-b543-150c25de1083','HTTP 202：仅确认受理，需核对完成状态。',NULL,'2026-10-19 10:56:48','2026-10-19 10:58:50'),('01a15586-041d-73ec-9fad-e895e090e247','01a15586-041c-730f-90bb-a0c3df1d6f93','create','创建联系人','demo.crm','{\"id\": \"crm.contact.create\", \"name\": \"创建联系人\", \"path\": \"/contacts\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.crm\"}','{\"contact_id\": \"$event.payload.contact_id\"}','[]','succeeded',1,1,5,'2026-10-19 10:56:48','2026-10-20 10:56:48',NULL,NULL,NULL,'c318c921-ecdb-46e4-b1e3-29d4e1f2ca69',NULL,'eyJpdiI6ImdvUzl4WUYrTXFsV2MzUXBFUzNtdmc9PSIsInZhbHVlIjoib1pTNE5qQU82REhyMkRya1E3TFM4KzJ2ZjdQbWQzdHpqbDQ4U2tYdHN0OFRCUkhCT1VYc2NUNnJkMWY0Y3BZc1BzRjhlWmpySFdEcndnS3Yya2NPcFE9PSIsIm1hYyI6IjlkYzM2OTI2ZmU1OTI0YmM2NjcyMTE3NjVjMjk3ZDRiNjNlZmQyOTk3Njc3NTY1NWE4YTRkYTIyM2E0OWExM2UiLCJ0YWciOiIifQ==','2026-10-19 10:56:48','2026-10-19 10:58:52'),('01a15586-041d-73ec-9fad-e895e105b0a1','01a15586-041c-730f-90bb-a0c3df1d6f93','mark-paid','更新付费状态','demo.crm','{\"id\": \"crm.contact.paid\", \"name\": \"更新付费状态\", \"path\": \"/paid\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.crm\"}','{\"order_id\": \"$event.payload.order_id\", \"contact_id\": \"$steps.create.output.id\"}','[\"create\"]','succeeded',1,1,5,'2026-10-19 10:56:48','2026-10-20 10:56:48',NULL,NULL,NULL,'d2d992b0-65e5-4677-84af-6a153414d059',NULL,'eyJpdiI6IkZxcGZQdmFXTldIRktNVGs3VEp5UEE9PSIsInZhbHVlIjoiYlBXNFFsZDFZbnJlTVNtOUxpR21NejRFemNDZUhteGtkZkVWZjdRZ09PMHJSbW1BVlgvTjRISUhrY1M4NFdDZGF6YkJHRzI0S05uTDA3RDVBRG9SaWc9PSIsIm1hYyI6IjFiY2Y2ZGM2MGQwZTc3OWRkZWZhMWJmOWE2ZjBhYTMzOGU5ZWI3NzRlZjAyMTRmMmUxZWYwMGZlMmUzNDA4MWUiLCJ0YWciOiIifQ==','2026-10-19 10:56:48','2026-10-19 10:58:53'),('01a15586-041e-7042-9862-87d8a582ffd3','01a15586-041e-7042-9862-87d8a529b4a5','send','发送短信','demo.sms','{\"id\": \"sms.order.confirm\", \"name\": \"发送订单确认短信\", \"path\": \"/sms\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.sms\"}','{\"order_id\": \"$event.payload.order_id\"}','[]','blocked',0,0,5,'2026-10-19 10:56:48','2026-10-20 10:56:48',NULL,NULL,NULL,'ae1deac9-9f50-498d-a9cd-ac4580f549f3',NULL,NULL,'2026-10-19 10:56:48','2026-10-19 10:58:50'),('01a15592-72de-7152-992e-cf6de93f1cbd','01a15592-72db-720d-a297-991211cf581f','reserve','预留库存','demo.inventory','{\"id\": \"inventory.reserve\", \"name\": \"预留库存\", \"path\": \"/reserve\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.inventory\"}','{\"order_id\": \"$event.payload.order_id\"}','[]','succeeded',1,1,5,'2026-10-19 11:10:23','2026-10-20 11:10:23',NULL,NULL,NULL,'535210ac-2603-488e-b32d-c7420e4ab03e',NULL,'eyJpdiI6IjJvbGZGTFVwRkcrZjZ1dXM5RTNwUVE9PSIsInZhbHVlIjoiNDZZUFBibjJsLy9JdTlkNkU0d2ZlM0VBT09SczhQa20rd3dpWWF3Qm5zZnR6d1QwQkw0TjhtaVVDR2Y0MlpTaWNqYlhuZmwyeTZvckNISGN6bnJ0VlE9PSIsIm1hYyI6IjY1OWQyOTBjMzY3YTMzZDY0ODFhZDIwMGJiY2ZjZDQwMGRiZTA4NmQxNzVhZTc4NWNkMjY3NzFiNmFjNGM3NDYiLCJ0YWciOiIifQ==','2026-10-19 11:10:23','2026-10-19 11:10:24'),('01a15592-72e0-7228-82d1-cac9d88fad39','01a15592-72df-7137-8324-52faec78de78','create','创建联系人','demo.crm','{\"id\": \"crm.contact.create\", \"name\": \"创建联系人\", \"path\": \"/contacts\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.crm\"}','{\"contact_id\": \"$event.payload.contact_id\"}','[]','succeeded',1,1,5,'2026-10-19 11:10:23','2026-10-20 11:10:23',NULL,NULL,NULL,'99819894-e896-40c8-bd5e-844903052dee',NULL,'eyJpdiI6IjVkUzlzK3YwSlRvN3NtZmN1RithUXc9PSIsInZhbHVlIjoia2YvdG94NHhrOXYyUkREcUpIWGtSNmlLQ3NqU3VxT1NmUmtnQUZYMXBITUptbytFQ3JVTUtDbmllb1o1bkJqUDhHaHBTdk4zcFVvamh3UWV0ZVYwWEE9PSIsIm1hYyI6IjhmN2IxMjFjZGQzYzZkOTg4YmM0MzhlOTE2NjFkYzczNzY4NTFiNmY4NzJjMmFiNjEwZTkwYTJkZDEwNjdkMTciLCJ0YWciOiIifQ==','2026-10-19 11:10:23','2026-10-19 11:10:24'),('01a15592-72e1-7054-8a2e-5d6c4752274a','01a15592-72df-7137-8324-52faec78de78','mark-paid','更新付费状态','demo.crm','{\"id\": \"crm.contact.paid\", \"name\": \"更新付费状态\", \"path\": \"/paid\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.crm\"}','{\"order_id\": \"$event.payload.order_id\", \"contact_id\": \"$steps.create.output.id\"}','[\"create\"]','succeeded',1,1,5,'2026-10-19 11:10:23','2026-10-20 11:10:23',NULL,NULL,NULL,'33088535-9071-42e2-bfee-c7e615cd2c80',NULL,'eyJpdiI6IkM3cUpEcjlhNTNqYkJEakNqeGhURlE9PSIsInZhbHVlIjoiVDNWTWtOdXZNSE9IZTZ5MVN6TytjL2xpd1Q3MHdrZldORDdnb01WRW5xckNZQWVWUGhrbElHUXBNN2lmOW0zOGhUa2l5VVZzVlczQ1BqTWVwVTJJdHc9PSIsIm1hYyI6IjM5NjhjOTIwZDcxYTA0Njc2ZjNhMDdmYWZjYmMxYTNlMDY5ODA3ODU5MDE2YThlM2MwZjZhYzliZTAzMWQ2YzMiLCJ0YWciOiIifQ==','2026-10-19 11:10:23','2026-10-19 11:10:26'),('01a15592-72e3-72ef-8a2e-11067220375f','01a15592-72e2-73d9-af8b-f98dd4674d6d','send','发送短信','demo.sms','{\"id\": \"sms.order.confirm\", \"name\": \"发送订单确认短信\", \"path\": \"/sms\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.sms\"}','{\"order_id\": \"$event.payload.order_id\"}','[]','succeeded',1,1,5,'2026-10-19 11:10:23','2026-10-20 11:10:23',NULL,NULL,NULL,'31f52201-308c-49c9-87a1-46130485eac2',NULL,'eyJpdiI6IjQvVjVueXJFY2RSODZkVEc4YUFwYWc9PSIsInZhbHVlIjoiQy8xb28wQVdXSXY1bThnQlc1WkhqbTFCM0JXbWlIakE2MHRBNDlIeWRqOWl6dU5UM1JWWHk2cDJYUUZDTUJ3QXB6SEhGYzhBTWdGYXR5OWM0clI4NkE9PSIsIm1hYyI6ImU0ZjhkYWU4OTkxZTE0YTJkOTMxNGI4YWUyMzM5ZmRiOWJhMjM5YjZhMTQzYWE2MWY1NmMxNjJhZGY1MTJhNTQiLCJ0YWciOiIifQ==','2026-10-19 11:10:23','2026-10-19 11:10:25'),('01a15592-72e6-729d-844b-01d3dfaa52a6','01a15592-72e6-729d-844b-01d3df79840d','reserve','预留库存','demo.inventory','{\"id\": \"inventory.reserve\", \"name\": \"预留库存\", \"path\": \"/reserve\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.inventory\"}','{\"order_id\": \"$event.payload.order_id\"}','[]','succeeded',2,2,5,'2026-10-19 11:10:37','2026-10-20 11:10:23',NULL,NULL,NULL,'031bc79b-67f6-422b-9057-c7b2508581b5',NULL,'eyJpdiI6IkJadWJzSTdOR2tkSnlNaUFCY1VEV2c9PSIsInZhbHVlIjoiZXNwekRpQ1NSTEtKcmhvaTdneUpoVzVzc2ZjeEJKNHFIdi95bzJxa1EyeG9WR1l5bmhhdjlIdHpjaDdMWjhIYTRwaVNlOVNLS3BtSFN0ejhnUnZQYVE9PSIsIm1hYyI6ImU5MzgzNTQzOTgwOGI0YjVkOGFjYTIyMjE0ODY0ZDA4M2JiM2JjODRiNDg0YTg2NzVjNThlOGNhZTkzNDFkZTYiLCJ0YWciOiIifQ==','2026-10-19 11:10:23','2026-10-19 11:10:38'),('01a15592-72e8-73f2-bafd-697d6808309a','01a15592-72e7-7224-a1ec-47f5120cea9a','create','创建联系人','demo.crm','{\"id\": \"crm.contact.create\", \"name\": \"创建联系人\", \"path\": \"/contacts\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.crm\"}','{\"contact_id\": \"$event.payload.contact_id\"}','[]','succeeded',1,1,5,'2026-10-19 11:10:23','2026-10-20 11:10:23',NULL,NULL,NULL,'f8bd4111-2f74-4cf1-b7b5-e82ad3231995',NULL,'eyJpdiI6IjNwWmQvVUF6NGRlNXM4dERVZ2N4Unc9PSIsInZhbHVlIjoibVRxRVhqR2VnbHM4WGU2aXEzVmVjWExlMjNUQ2Z1cC9rZnozcHpKMDZWamY4M01HUmdXc3B4VXIrQjJrYk4yL0FjTHVyS1FuR2NpTlhPTGlTK2VHT0E9PSIsIm1hYyI6Ijg1ZWEyZTFiY2IzMmE5NTZlZWI3ZjViOTVhMmYwMGRmYjBiM2IzY2UyNTg1NTkwN2UwNmJkZThjYzlkOWZkZTgiLCJ0YWciOiIifQ==','2026-10-19 11:10:23','2026-10-19 11:10:28'),('01a15592-72e9-7317-8151-af573dcdde54','01a15592-72e7-7224-a1ec-47f5120cea9a','mark-paid','更新付费状态','demo.crm','{\"id\": \"crm.contact.paid\", \"name\": \"更新付费状态\", \"path\": \"/paid\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.crm\"}','{\"order_id\": \"$event.payload.order_id\", \"contact_id\": \"$steps.create.output.id\"}','[\"create\"]','succeeded',1,1,5,'2026-10-19 11:10:23','2026-10-20 11:10:23',NULL,NULL,NULL,'0f4b2165-c00f-44b7-a5ff-5930dea249e4',NULL,'eyJpdiI6InBnUGdEZ21sZ3l4N1dpM2NjZ29DblE9PSIsInZhbHVlIjoiZWU2bjcyMlMvVW42djVlSWFBbUNHdHFKVGJOQlVjUitkOUt5Q0l2VmhwTlRKWGZ1N0RrZ004M1NLVWZnN0hiSSszRmNTZlNCZ3dBNDhIK3BJL1hUdVE9PSIsIm1hYyI6IjgzNmMwZjMyYzE1YjhhMTIyOThjMzI4ZTBiNjk0Yzg0ZTZmYTY4NjY0ZTdiOWVkZDM2YmU4NWNjNzQ5MWVmMDgiLCJ0YWciOiIifQ==','2026-10-19 11:10:23','2026-10-19 11:10:30'),('01a15592-72eb-700f-bfa9-db0245be2600','01a15592-72ea-70e1-a607-9c3e90c7bcd7','send','发送短信','demo.sms','{\"id\": \"sms.order.confirm\", \"name\": \"发送订单确认短信\", \"path\": \"/sms\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.sms\"}','{\"order_id\": \"$event.payload.order_id\"}','[]','succeeded',1,1,5,'2026-10-19 11:10:23','2026-10-20 11:10:23',NULL,NULL,NULL,'5c407f72-8b3e-43ae-a24d-a93c4275f846',NULL,'eyJpdiI6IkIzaHRLNEtKcEh2cDBmNWJROHB6WHc9PSIsInZhbHVlIjoiSGx1RTF5K2hSRjErYlQ1NGkwQ0Vka2VaZUs4RVdUM3ZGRzV1bUJ1UnhYdWVZdHdUR0xoSjlxNndxWTJvbkVnV3RPcDU2eXY5dWQ3czlvL2hGaE9oamc9PSIsIm1hYyI6IjJkY2Q4N2QxNzgzYTc5ZGJiNWU1ZWIyZTU1YTM1MDU3NjY5ZTA0OTgzZTU3ZTZmMDI0ZDc1YTMzOGUzMTY3MTgiLCJ0YWciOiIifQ==','2026-10-19 11:10:23','2026-10-19 11:10:39'),('01a15592-72ed-7039-b4a4-b5167c78ffd5','01a15592-72ed-7039-b4a4-b5167c02d005','reserve','预留库存','demo.inventory','{\"id\": \"inventory.reserve\", \"name\": \"预留库存\", \"path\": \"/reserve\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.inventory\"}','{\"order_id\": \"$event.payload.order_id\"}','[]','dead',1,1,5,'2026-10-19 11:10:23','2026-10-20 11:10:23',NULL,NULL,NULL,'ec7bae27-d190-40d8-a17c-2008f832fb2e','HTTP 400：请求被拒绝或业务结果未满足成功条件。',NULL,'2026-10-19 11:10:23','2026-10-19 11:10:28'),('01a15592-72ee-721c-ad1f-907e6f0c8f77','01a15592-72ee-721c-ad1f-907e6e4db95c','create','创建联系人','demo.crm','{\"id\": \"crm.contact.create\", \"name\": \"创建联系人\", \"path\": \"/contacts\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.crm\"}','{\"contact_id\": \"$event.payload.contact_id\"}','[]','succeeded',1,1,5,'2026-10-19 11:10:23','2026-10-20 11:10:23',NULL,NULL,NULL,'0ffbcb9e-268c-4a8f-86d1-816fb7894294',NULL,'eyJpdiI6IlRRekFYNWhZaVR1aEZVZ3VEajFjRWc9PSIsInZhbHVlIjoiTWdidHlpWlBSVGcrMFAwcmZ6UG9YUFY4OTFBNXZreGpEdWVkOGZYYzUzaHNuZFIrU3hrbmZScTFjd08rOHlBS2kvZHo3OUxQRS8rOE55eHBGNnpKUlE9PSIsIm1hYyI6IjIyN2U0ZjAwNDZjODM1YjIwNDYzN2EyZWE4ZDVmYjYyOWViNDZjNGRjNWYzMDA3MWQyMGEzZjc5OWQ4ZDRkOTAiLCJ0YWciOiIifQ==','2026-10-19 11:10:23','2026-10-19 11:10:32'),('01a15592-72ef-72ab-baa6-b0e0254b3ce6','01a15592-72ee-721c-ad1f-907e6e4db95c','mark-paid','更新付费状态','demo.crm','{\"id\": \"crm.contact.paid\", \"name\": \"更新付费状态\", \"path\": \"/paid\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.crm\"}','{\"order_id\": \"$event.payload.order_id\", \"contact_id\": \"$steps.create.output.id\"}','[\"create\"]','succeeded',1,1,5,'2026-10-19 11:10:23','2026-10-20 11:10:23',NULL,NULL,NULL,'17fd5941-94a4-4b67-bbb8-8e287f50a893',NULL,'eyJpdiI6ImxYamVZWkoxVVVBZHAyZ0JsdUJ2MEE9PSIsInZhbHVlIjoiZm16UTZLVnc1ZkYvU09veUw2Ym82Z3dma3RUZ3NzekM2OGtJZDlKUkJ5Y0YzaW5Nc0RlMmZjRjdoaVl4WHdGWk5SblB0RTMrRis2T2s5TUhaUmZ2eEE9PSIsIm1hYyI6IjIyYjM0NGY3NWIwYmUyMzVlODc1NjcwM2ZkYTc5MzJlM2Y3ZWMxMjQzMzM1ZjdjZmYyZmExZDMxNjRiYTUwOGMiLCJ0YWciOiIifQ==','2026-10-19 11:10:23','2026-10-19 11:10:34'),('01a15592-72f1-72e6-b5f2-2b90ea0dbb58','01a15592-72f0-71ae-a539-9587b6d07dd6','send','发送短信','demo.sms','{\"id\": \"sms.order.confirm\", \"name\": \"发送订单确认短信\", \"path\": \"/sms\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.sms\"}','{\"order_id\": \"$event.payload.order_id\"}','[]','blocked',0,0,5,'2026-10-19 11:10:23','2026-10-20 11:10:23',NULL,NULL,NULL,'49b2239d-767e-4f03-ba15-3b1940b24b22',NULL,NULL,'2026-10-19 11:10:23','2026-10-19 11:10:28'),('01a15592-72f4-7201-9cd4-a6d68208d198','01a15592-72f3-7268-92e7-207da2e96ec7','reserve','预留库存','demo.inventory','{\"id\": \"inventory.reserve\", \"name\": \"预留库存\", \"path\": \"/reserve\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.inventory\"}','{\"order_id\": \"$event.payload.order_id\"}','[]','unknown',1,1,5,'2026-10-19 11:10:23','2026-10-20 11:10:23',NULL,NULL,NULL,'4056e630-9eae-40d9-9d65-5c4a044bccd6','HTTP 202：仅确认受理，需核对完成状态。',NULL,'2026-10-19 11:10:23','2026-10-19 11:10:30'),('01a15592-72f5-70db-abf0-ac45367419e8','01a15592-72f4-7201-9cd4-a6d682c6e711','create','创建联系人','demo.crm','{\"id\": \"crm.contact.create\", \"name\": \"创建联系人\", \"path\": \"/contacts\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.crm\"}','{\"contact_id\": \"$event.payload.contact_id\"}','[]','succeeded',1,1,5,'2026-10-19 11:10:23','2026-10-20 11:10:23',NULL,NULL,NULL,'db52c25a-4687-402a-8ccf-dba7dfcd99d7',NULL,'eyJpdiI6ImNiaytUVGM2dzArMW9PRlVnaVRiU2c9PSIsInZhbHVlIjoiVE5Kc21yN1p5OWFmSWFXa1VvQ0JYUG1wdDJ0L1krMGtrbm5Ya3g3dnIwSWswbUJKeFF5QnBVdlpwcmRSKzhrcmVNRjFlTUlzQmwvYlpVOHc1VWVqVFE9PSIsIm1hYyI6ImJkMzk2Y2U2NWMxNDk1Y2U3MjVmZDg5NzExYjNhNGNkM2E2YmI3NmViMTU5ZjdiYjBkMTBjYTAxY2Y4NDVkYTEiLCJ0YWciOiIifQ==','2026-10-19 11:10:23','2026-10-19 11:10:36'),('01a15592-72f5-70db-abf0-ac453733005a','01a15592-72f4-7201-9cd4-a6d682c6e711','mark-paid','更新付费状态','demo.crm','{\"id\": \"crm.contact.paid\", \"name\": \"更新付费状态\", \"path\": \"/paid\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.crm\"}','{\"order_id\": \"$event.payload.order_id\", \"contact_id\": \"$steps.create.output.id\"}','[\"create\"]','succeeded',1,1,5,'2026-10-19 11:10:23','2026-10-20 11:10:23',NULL,NULL,NULL,'68a998bf-ac3c-4776-907c-e09d29fd6c6b',NULL,'eyJpdiI6ImJ4VWt6a0txa1FqMFRVbVdjaUVES0E9PSIsInZhbHVlIjoiVU5jTzRBdjJiZklvQ0ptaHlVU3BZK29tMUZiQmhETnI0N1dqRCtZTWo1eFE0ekJvQ1U1UzNMbHc1S3VhbnB5TnRGV3dGQm45USs1SU5IZWx3eFpZNFE9PSIsIm1hYyI6ImJlODg4OThjN2NkNGVhMDAzOTBjNDlhN2E2NDRlZGVjOTY0ZmYzNGZkNzZlZDYyYjk2MDI4ZTY5ZDA2ZjMwMmUiLCJ0YWciOiIifQ==','2026-10-19 11:10:23','2026-10-19 11:10:38'),('01a15592-72f7-715e-a8e2-4ee7c24de27d','01a15592-72f6-7234-9679-7c600b6d893f','send','发送短信','demo.sms','{\"id\": \"sms.order.confirm\", \"name\": \"发送订单确认短信\", \"path\": \"/sms\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.sms\"}','{\"order_id\": \"$event.payload.order_id\"}','[]','blocked',0,0,5,'2026-10-19 11:10:23','2026-10-20 11:10:23',NULL,NULL,NULL,'ff47fea6-0649-4a7c-b044-25394c7e164c',NULL,NULL,'2026-10-19 11:10:23','2026-10-19 11:10:30'),('01a155a5-a2ad-7284-9017-cbc4e910a2de','01a155a5-a2a8-7390-8af1-921c6173b6a6','reserve','预留库存','demo.inventory','{\"id\": \"inventory.reserve\", \"name\": \"预留库存\", \"path\": \"/reserve\", \"driver\": \"demo.inventory.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true}, \"base_url\": \"http://127.0.0.1:9081\", \"operation\": \"stock.reserve\", \"provider_id\": \"demo.inventory\"}','{\"order_id\": \"$event.payload.order_id\"}','[]','succeeded',1,1,5,'2026-10-19 11:31:20','2026-10-20 11:31:20',NULL,NULL,NULL,'277fbca7-7c5d-4340-9516-4ddeb702f8a9',NULL,'eyJpdiI6IjBCbHdWNjRtZU5lT0szZ1kzK0wyNkE9PSIsInZhbHVlIjoiVGZNdDJYM2Q4QllvK2d4T1dZLy8vWXFPRmNXV3dtK0NHY3FnN3NxQWxZV3BTcDlpbWQ1bEYvVHNSL2ltQ29UZVlTWjJPL2toSWxKMHNCSGhFNkE3Ymc9PSIsIm1hYyI6ImQ1ZmI2NmEyZTNmYTY2NzQwNjAzZTI4NzI3OGZhNWFkYjk5MWY0YjQxZjIwYzRiYTAyODRjYWM3YzE2Y2ZkZDciLCJ0YWciOiIifQ==','2026-10-19 11:31:20','2026-10-19 11:31:21'),('01a155a5-a2b0-72a7-b94e-49d5687efc58','01a155a5-a2af-7280-8ba9-bef08814f2d4','create','创建联系人','demo.crm','{\"id\": \"crm.contact.create\", \"name\": \"创建联系人\", \"path\": \"/contacts\", \"driver\": \"demo.crm.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true}, \"base_url\": \"http://127.0.0.1:9081\", \"operation\": \"contact.create\", \"provider_id\": \"demo.crm\"}','{\"contact_id\": \"$event.payload.contact_id\"}','[]','succeeded',1,1,5,'2026-10-19 11:31:20','2026-10-20 11:31:20',NULL,NULL,NULL,'00f055b5-fbde-42bb-a249-716fe3b836a9',NULL,'eyJpdiI6IkovUm1SMi80L1RlR0lyUTRsSnJLWWc9PSIsInZhbHVlIjoibEw0c0xSSDlBNjZ1cW1ocHJodEpCV0JBamxqUmQ1VkNtOG84UUZkamVpcjJYRGcyZ3M2VFNLcFRwM01KRVA5YlFqblJZV0ZkbUNMa2tWSU12c1ZlSXc9PSIsIm1hYyI6ImM4NTdhNWEyNDM1ODgyNzM4MzI4MmE3NDYzMWFmN2EyMmMzZTc4MmVhNTdiNGJjYjYxZmQ0YzM5YzU5ZDA5OGEiLCJ0YWciOiIifQ==','2026-10-19 11:31:20','2026-10-19 11:31:21'),('01a155a5-a2b1-7244-9521-1a8247c1a8fe','01a155a5-a2af-7280-8ba9-bef08814f2d4','mark-paid','更新付费状态','demo.crm','{\"id\": \"crm.contact.paid\", \"name\": \"更新付费状态\", \"path\": \"/contacts/{contact_id}/paid\", \"driver\": \"demo.crm.v1\", \"method\": \"PATCH\", \"options\": {\"timeout\": 10, \"idempotent\": true}, \"base_url\": \"http://127.0.0.1:9081\", \"operation\": \"contact.mark-paid\", \"provider_id\": \"demo.crm\"}','{\"order_id\": \"$event.payload.order_id\", \"contact_id\": \"$steps.create.output.id\"}','[\"create\"]','succeeded',1,1,5,'2026-10-19 11:31:20','2026-10-20 11:31:20',NULL,NULL,NULL,'1afee0f7-803f-475d-8ad1-245c6507655a',NULL,'eyJpdiI6ImNwQ2hFOU9MaDJJaWJneUl2enhGN0E9PSIsInZhbHVlIjoidGN4MzA2MmxjWi8yakNpdE5LTXZrSU1XUjl2VFRSL2JvTHlZOHVHSm44VWdpaDgrRitPaEdGM25LVzQrVDRzQy9EcWRlOWRnT3BZTnZTNm11bVVhZTNScnFYZENPVmZiVjYzV3N5VnlQZGc9IiwibWFjIjoiM2VkMDVlNTgxZTM1MmQ0ZDlmNTUyNzk3OGM1M2ViNzYwODA4OWU1NGFiNzJlNzA0YzI0YjM0MTU2MTM4MWY5ZCIsInRhZyI6IiJ9','2026-10-19 11:31:20','2026-10-19 11:31:22'),('01a155a5-a2b2-7166-bb97-24da38dda7c7','01a155a5-a2b1-7244-9521-1a82487e76fa','send','发送短信','demo.sms','{\"id\": \"sms.order.confirm\", \"name\": \"发送订单确认短信\", \"path\": \"/sms\", \"driver\": \"demo.sms.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true}, \"base_url\": \"http://127.0.0.1:9081\", \"operation\": \"order.confirm\", \"provider_id\": \"demo.sms\"}','{\"order_id\": \"$event.payload.order_id\"}','[]','succeeded',1,1,5,'2026-10-19 11:31:20','2026-10-20 11:31:20',NULL,NULL,NULL,'e0b717af-003d-4a9e-af19-738c590b67a2',NULL,'eyJpdiI6IlVwYTJpSWxXQmFqK0FtTzhuQ3BCcXc9PSIsInZhbHVlIjoiK3dsUmN0VXA4OWc4VGx2TG9Lc1AyM2hnWW1YUDl1OFBBSXRBc1pnNzNwL1Zzb2xwM1NaQWJUbkpkbk0wd2t5b1VYRHVMV1lMTS9HdUZRTTE1Y1Nianc9PSIsIm1hYyI6ImRmZWY1NmI4MjA0NjlmODU4YWFjMjBiMWNjYWViNTgyY2UyOGIxYjliY2NkOWQ5OTIzZTQ0YjRjODEzYjUyY2YiLCJ0YWciOiIifQ==','2026-10-19 11:31:20','2026-10-19 11:31:22'),('01a155a5-a2b6-723b-bf70-f11a5765e910','01a155a5-a2b5-726c-ac1c-41f500f7a3ef','reserve','预留库存','demo.inventory','{\"id\": \"inventory.reserve\", \"name\": \"预留库存\", \"path\": \"/reserve\", \"driver\": \"demo.inventory.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true}, \"base_url\": \"http://127.0.0.1:9081\", \"operation\": \"stock.reserve\", \"provider_id\": \"demo.inventory\"}','{\"order_id\": \"$event.payload.order_id\"}','[]','succeeded',2,2,5,'2026-10-19 11:31:34','2026-10-20 11:31:20',NULL,NULL,NULL,'93b429e1-0965-4224-bd19-37903c7156ed',NULL,'eyJpdiI6IldHV2hCTWkyTHdzdzFvcnZHK3ZJN0E9PSIsInZhbHVlIjoidm1Nc01Ec1QvcE0vMmNIVnBJWUVpT3h4L0dzamcwanlsamowNVZyNlpsZGo0Si93Z1VXcVVBdVRqU3daNjd3M1F4K25wZm1jUk0ySUN6a3RiWld6QWc9PSIsIm1hYyI6IjY0OTdlOTE5Y2QzNDc4NmVmNDg5MTVhNTk4YjA3OGY5YTU4MGUyMDBlNGMwNjQ1ZDE3NGYzMzY5Yzg2NGNjYTkiLCJ0YWciOiIifQ==','2026-10-19 11:31:20','2026-10-19 11:31:35'),('01a155a5-a2b8-72ca-a7e4-860d2df300b8','01a155a5-a2b7-73c5-b4eb-d572c4b8d0e8','create','创建联系人','demo.crm','{\"id\": \"crm.contact.create\", \"name\": \"创建联系人\", \"path\": \"/contacts\", \"driver\": \"demo.crm.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true}, \"base_url\": \"http://127.0.0.1:9081\", \"operation\": \"contact.create\", \"provider_id\": \"demo.crm\"}','{\"contact_id\": \"$event.payload.contact_id\"}','[]','succeeded',1,1,5,'2026-10-19 11:31:20','2026-10-20 11:31:20',NULL,NULL,NULL,'bda7bc38-3d3b-4371-ad8a-aa34758e9987',NULL,'eyJpdiI6IlNndjNsa3ZZYTVKRjdsb2IySDM4THc9PSIsInZhbHVlIjoiZmxyb3ViSHkwSHd0akhxWGVxNHRSOGFwTDU0UzJqcDdFR0ZzUUZQNjRSRE9ldUN1Tm4ybXFkR2RCUFNpdlhuVGdpUm9GajFoZ3BQOTU5TTJDNnhPU1E9PSIsIm1hYyI6ImJmOTJlODM1MmY4YzcxOGU0NTZjYTVlMDMzZmI3OTYwM2RjMTcxYTcwZjY2MmZmNDVkMDc3YjEwZmMwN2NmM2EiLCJ0YWciOiIifQ==','2026-10-19 11:31:20','2026-10-19 11:31:23'),('01a155a5-a2b9-7075-be94-2292a5baf9c8','01a155a5-a2b7-73c5-b4eb-d572c4b8d0e8','mark-paid','更新付费状态','demo.crm','{\"id\": \"crm.contact.paid\", \"name\": \"更新付费状态\", \"path\": \"/contacts/{contact_id}/paid\", \"driver\": \"demo.crm.v1\", \"method\": \"PATCH\", \"options\": {\"timeout\": 10, \"idempotent\": true}, \"base_url\": \"http://127.0.0.1:9081\", \"operation\": \"contact.mark-paid\", \"provider_id\": \"demo.crm\"}','{\"order_id\": \"$event.payload.order_id\", \"contact_id\": \"$steps.create.output.id\"}','[\"create\"]','succeeded',1,1,5,'2026-10-19 11:31:20','2026-10-20 11:31:20',NULL,NULL,NULL,'7ca96588-0a74-4f58-8eb5-fe0efae0a4ac',NULL,'eyJpdiI6InRUbld6ZDR5T1BEYkJvck9GbUFRUGc9PSIsInZhbHVlIjoiSlpqamRCbjRycTVMWGpzWjU0YmtPc0N0anlraEoxdi90Y3hnL3dTbFM0UHg2MXpNZlJ1Mm1MYWdoQmw2eExsUHdHOUd0Wmx3dnVBOGZZOE1zeEErMHlVcklEbHM3Q0hqcDljY0Njb29PYjQ9IiwibWFjIjoiYjMwNTMwOWIxMDY1ZjdkMzhiZWRiNzJjYTU5MTJlZDZhY2FjOWFkZWU3ODRiZWYyZGY2NmJjY2RiMGJjMGRiYSIsInRhZyI6IiJ9','2026-10-19 11:31:20','2026-10-19 11:31:24'),('01a155a5-a2ba-71ed-aef5-0f50a4428eee','01a155a5-a2b9-7075-be94-2292a6304e83','send','发送短信','demo.sms','{\"id\": \"sms.order.confirm\", \"name\": \"发送订单确认短信\", \"path\": \"/sms\", \"driver\": \"demo.sms.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true}, \"base_url\": \"http://127.0.0.1:9081\", \"operation\": \"order.confirm\", \"provider_id\": \"demo.sms\"}','{\"order_id\": \"$event.payload.order_id\"}','[]','succeeded',1,1,5,'2026-10-19 11:31:20','2026-10-20 11:31:20',NULL,NULL,NULL,'450a823b-46a4-4800-9485-ce231ef706a1',NULL,'eyJpdiI6IjVqNkZLdEtYT3g1RjJyZDVBbXV1MUE9PSIsInZhbHVlIjoiZkp3RDhlZDUvY3NhQ3VYSmRyakJsZUptQjEvRC9oOXdsSWNkakNGcXplSXRvcTByQldjbkxpTlhNMTF6b2JsLzJpMmplRHY0bUFiNVBUNlV4MTEwWEE9PSIsIm1hYyI6IjYxMzk5M2FmNWEyMmQ5NzViOWNkODBiNjVkODNiNTFiOGU5MmNhYmI2ZjI1ODUwYmRhOWNlODE2MGMyYTg2YTgiLCJ0YWciOiIifQ==','2026-10-19 11:31:20','2026-10-19 11:31:36'),('01a155a5-a2bd-724e-ac12-713a05c37750','01a155a5-a2bd-724e-ac12-713a056c455a','reserve','预留库存','demo.inventory','{\"id\": \"inventory.reserve\", \"name\": \"预留库存\", \"path\": \"/reserve\", \"driver\": \"demo.inventory.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true}, \"base_url\": \"http://127.0.0.1:9081\", \"operation\": \"stock.reserve\", \"provider_id\": \"demo.inventory\"}','{\"order_id\": \"$event.payload.order_id\"}','[]','dead',1,1,5,'2026-10-19 11:31:20','2026-10-20 11:31:20',NULL,NULL,NULL,'9a9aa514-37f5-4b6d-a13a-49c7cd094da3','HTTP 400：请求被拒绝或业务结果未满足成功条件。',NULL,'2026-10-19 11:31:20','2026-10-19 11:31:23'),('01a155a5-a2bf-72c9-bbe9-3cd52cb965d1','01a155a5-a2be-7361-a1bf-cf6bf66f354b','create','创建联系人','demo.crm','{\"id\": \"crm.contact.create\", \"name\": \"创建联系人\", \"path\": \"/contacts\", \"driver\": \"demo.crm.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true}, \"base_url\": \"http://127.0.0.1:9081\", \"operation\": \"contact.create\", \"provider_id\": \"demo.crm\"}','{\"contact_id\": \"$event.payload.contact_id\"}','[]','succeeded',1,1,5,'2026-10-19 11:31:20','2026-10-20 11:31:20',NULL,NULL,NULL,'1288024d-7a31-4f89-a983-22770c2f354f',NULL,'eyJpdiI6IkJidDhKZ05kaW5EbGVFUTZXaU9HMGc9PSIsInZhbHVlIjoiN2tkNEtxTG4xNXROVDhZN3Vjanl4Y1VOT1hpYVAvbVgwQlpWYmVIZzdTWkVwNGN2VHUxMDdtaC9Ta2UzUCszajBnM0ZQU0xKa3JEZHNncGpMcmRvS1E9PSIsIm1hYyI6ImM2MGRjOGYyOGVlYTgyYjFlMzZlNzRmMjM4MDg4N2VkOTdhYTMyOWU4YmQ2MGRlZjJkODMxMTk2N2EzMGIzNWIiLCJ0YWciOiIifQ==','2026-10-19 11:31:20','2026-10-19 11:31:25'),('01a155a5-a2bf-72c9-bbe9-3cd52d776b06','01a155a5-a2be-7361-a1bf-cf6bf66f354b','mark-paid','更新付费状态','demo.crm','{\"id\": \"crm.contact.paid\", \"name\": \"更新付费状态\", \"path\": \"/contacts/{contact_id}/paid\", \"driver\": \"demo.crm.v1\", \"method\": \"PATCH\", \"options\": {\"timeout\": 10, \"idempotent\": true}, \"base_url\": \"http://127.0.0.1:9081\", \"operation\": \"contact.mark-paid\", \"provider_id\": \"demo.crm\"}','{\"order_id\": \"$event.payload.order_id\", \"contact_id\": \"$steps.create.output.id\"}','[\"create\"]','succeeded',1,1,5,'2026-10-19 11:31:20','2026-10-20 11:31:20',NULL,NULL,NULL,'262eecb5-e1ad-415b-8679-706628ccce1b',NULL,'eyJpdiI6ImRQbUpCanFpMUtRZ3ZuWkJJMWRKMHc9PSIsInZhbHVlIjoiM291MGhGd1lMRW5oUlp5T2k3NFM5RngyQktnR0wxNE82dTBvQlp4R1Q1WndzYkhNMGhHNCtCMEZoSE9Va1NiWGcxRUd6TFdKWEV5VjYranlINTdhY2U4QUJPUGh0Umo0cVZ5dGgyRHhOaGc9IiwibWFjIjoiMzM2ZDhkZWQ4ZGE4NWRjMjAwZDViZDA1MTUwYjZlYWRkOGEwZDZlNDJjZGZmYjRhYTU2YjAwMGI4YTg5MGM1YSIsInRhZyI6IiJ9','2026-10-19 11:31:20','2026-10-19 11:31:26'),('01a155a5-a2c1-7203-ad7b-fd852f7ea40f','01a155a5-a2c0-7230-bdef-7b61aee41186','send','发送短信','demo.sms','{\"id\": \"sms.order.confirm\", \"name\": \"发送订单确认短信\", \"path\": \"/sms\", \"driver\": \"demo.sms.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true}, \"base_url\": \"http://127.0.0.1:9081\", \"operation\": \"order.confirm\", \"provider_id\": \"demo.sms\"}','{\"order_id\": \"$event.payload.order_id\"}','[]','blocked',0,0,5,'2026-10-19 11:31:20','2026-10-20 11:31:20',NULL,NULL,NULL,'843b0d85-dd57-48f1-9f23-3dc79ab36b22',NULL,NULL,'2026-10-19 11:31:20','2026-10-19 11:31:23'),('01a155a5-a2c4-71f4-988c-47dd68135084','01a155a5-a2c3-70ff-9910-749471e224f0','reserve','预留库存','demo.inventory','{\"id\": \"inventory.reserve\", \"name\": \"预留库存\", \"path\": \"/reserve\", \"driver\": \"demo.inventory.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true}, \"base_url\": \"http://127.0.0.1:9081\", \"operation\": \"stock.reserve\", \"provider_id\": \"demo.inventory\"}','{\"order_id\": \"$event.payload.order_id\"}','[]','unknown',1,1,5,'2026-10-19 11:31:20','2026-10-20 11:31:20',NULL,NULL,NULL,'788c77c6-1bb2-45ce-be2d-cec5792a56f7','HTTP 202：仅确认受理，需核对完成状态。',NULL,'2026-10-19 11:31:20','2026-10-19 11:31:24'),('01a155a5-a2c5-713d-b37d-8f4aced614d9','01a155a5-a2c5-713d-b37d-8f4ace3da070','create','创建联系人','demo.crm','{\"id\": \"crm.contact.create\", \"name\": \"创建联系人\", \"path\": \"/contacts\", \"driver\": \"demo.crm.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true}, \"base_url\": \"http://127.0.0.1:9081\", \"operation\": \"contact.create\", \"provider_id\": \"demo.crm\"}','{\"contact_id\": \"$event.payload.contact_id\"}','[]','succeeded',1,1,5,'2026-10-19 11:31:20','2026-10-20 11:31:20',NULL,NULL,NULL,'88f61ea9-001e-472b-b0a6-d0f73ead681c',NULL,'eyJpdiI6ImRyNGp3NThjQ3RacjNlaFlHOUFsMmc9PSIsInZhbHVlIjoiNUY4UWRiUVVSTFBsWjJUSStNMzdlQkJIMjJIdXNBc3V5YWdJU05rSHdvNHZYNStHY3VYelZzRGFpOUFscUdRcE8xN0p0ajF3NHRTWnV5WXpSQTlPamc9PSIsIm1hYyI6ImEzOWQ2ZGFlMDMzNjBmYTljODA1MzhiMDk1MGQzYzIzNmFhMGU3YTg5MGMxNTNlNTA2ODNjZDQ5MzcxN2M3ZDgiLCJ0YWciOiIifQ==','2026-10-19 11:31:20','2026-10-19 11:31:27'),('01a155a5-a2c6-723c-9be1-3cc7ef0ff6eb','01a155a5-a2c5-713d-b37d-8f4ace3da070','mark-paid','更新付费状态','demo.crm','{\"id\": \"crm.contact.paid\", \"name\": \"更新付费状态\", \"path\": \"/contacts/{contact_id}/paid\", \"driver\": \"demo.crm.v1\", \"method\": \"PATCH\", \"options\": {\"timeout\": 10, \"idempotent\": true}, \"base_url\": \"http://127.0.0.1:9081\", \"operation\": \"contact.mark-paid\", \"provider_id\": \"demo.crm\"}','{\"order_id\": \"$event.payload.order_id\", \"contact_id\": \"$steps.create.output.id\"}','[\"create\"]','succeeded',1,1,5,'2026-10-19 11:31:20','2026-10-20 11:31:20',NULL,NULL,NULL,'dd695baf-d4b3-4c88-b9d0-093089cd7513',NULL,'eyJpdiI6IjJhZk5MMWYwditFMlBydjQ2UDFob1E9PSIsInZhbHVlIjoiQUFKcGlMQVlsamRSaC9ZTU02TFRnMHU5YWlhbUNSYlBNVHZtRk9hNklUcXFUbFhIcDliSUJ6NzVDWHIxby9SN2kxbmRJcDhwTTlVaUt3NHRPV3UxMmlneUlTOGkzSzZLVVlvZGdMVWlHclE9IiwibWFjIjoiNTBhNDhlNmRjMDJkYjk1NmVlZTNhZTk1NWYxZWMzZDFkNDQ1MDViNDEzNjA5YmRmYWZlOTZjNmI0ZTllOTI1NCIsInRhZyI6IiJ9','2026-10-19 11:31:20','2026-10-19 11:31:28'),('01a155a5-a2c7-716d-9c31-880687f236b1','01a155a5-a2c6-723c-9be1-3cc7efe3a766','send','发送短信','demo.sms','{\"id\": \"sms.order.confirm\", \"name\": \"发送订单确认短信\", \"path\": \"/sms\", \"driver\": \"demo.sms.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true}, \"base_url\": \"http://127.0.0.1:9081\", \"operation\": \"order.confirm\", \"provider_id\": \"demo.sms\"}','{\"order_id\": \"$event.payload.order_id\"}','[]','blocked',0,0,5,'2026-10-19 11:31:20','2026-10-20 11:31:20',NULL,NULL,NULL,'0b5543a0-a91b-42b3-80a8-26590e72126d',NULL,NULL,'2026-10-19 11:31:20','2026-10-19 11:31:24'),('01a15778-5f0a-72de-8b42-dbf23df55030','01a15778-5f08-73ce-9d3a-9447ae9eaaf8','reserve','预留库存','demo.inventory','{\"id\": \"inventory.reserve\", \"name\": \"预留库存\", \"path\": \"/reserve\", \"driver\": \"demo.inventory.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true}, \"base_url\": \"http://127.0.0.1:9081\", \"operation\": \"stock.reserve\", \"provider_id\": \"demo.inventory\"}','{\"order_id\": \"$event.payload.order_id\"}','[]','succeeded',1,1,5,'2026-10-19 20:01:08','2026-10-20 20:01:08',NULL,NULL,NULL,'6aed0db2-46ff-4843-a2c8-13f575641acc',NULL,'eyJpdiI6IjY5NEVkOWFyTkQ1RVFiSWxIRWp3d2c9PSIsInZhbHVlIjoicVpkYnBTM0FvQXhsSjJjQTdxNml6WmV2ZXdtS0txSi8yU2pvQUhKczhCWStyaTVFbkkyZ1JiaTh2ZjdYK0xQMjhCcVVzM0F6cjd1QXVEeFZEOGhXcFE9PSIsIm1hYyI6IjlmMjVjYTk0OGFlZTc3ODlkZDFiM2NiNmIxOTk4NWE3NmUyYWU1YjkyNGJmMjhiOTk2NmJjYTIyMjY5ZDBlOWQiLCJ0YWciOiIifQ==','2026-10-19 20:01:08','2026-10-19 20:01:09'),('01a15778-5f0d-733a-8755-83f3cc04c776','01a15778-5f0c-703f-97df-1f8df8a6311d','create','创建联系人','demo.crm','{\"id\": \"crm.contact.create\", \"name\": \"创建联系人\", \"path\": \"/contacts\", \"driver\": \"demo.crm.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true}, \"base_url\": \"http://127.0.0.1:9081\", \"operation\": \"contact.create\", \"provider_id\": \"demo.crm\"}','{\"contact_id\": \"$event.payload.contact_id\"}','[]','succeeded',1,1,5,'2026-10-19 20:01:08','2026-10-20 20:01:08',NULL,NULL,NULL,'1c049b0f-a1b1-4986-9c62-f66cf8b2fbb8',NULL,'eyJpdiI6Im1IU21KdDk4bkV1L09KQUpQNy81bVE9PSIsInZhbHVlIjoiMlhLSWYzckRyQzJMM2swdnNDWGtsRW9yUXdWdkJpd0hFT0tPbDhnV1ZraFlUL2ppMENLUFd1OG1PVk5jcVM5alc5OHJqeCtuMFd1U3ZnYk9IV0dPOGc9PSIsIm1hYyI6IjUyMzRiZTE3YzIzMTJiYzA4NDY0YWQxMzVlNTBkODNjOWQ0NDYwN2Q1NWM2Zjc2NzFhOThlZGU0ZGE0MTc4MmMiLCJ0YWciOiIifQ==','2026-10-19 20:01:08','2026-10-19 20:01:09'),('01a15778-5f0e-7275-a1ce-2387045baad8','01a15778-5f0c-703f-97df-1f8df8a6311d','mark-paid','更新付费状态','demo.crm','{\"id\": \"crm.contact.paid\", \"name\": \"更新付费状态\", \"path\": \"/contacts/{contact_id}/paid\", \"driver\": \"demo.crm.v1\", \"method\": \"PATCH\", \"options\": {\"timeout\": 10, \"idempotent\": true}, \"base_url\": \"http://127.0.0.1:9081\", \"operation\": \"contact.mark-paid\", \"provider_id\": \"demo.crm\"}','{\"order_id\": \"$event.payload.order_id\", \"contact_id\": \"$steps.create.output.id\"}','[\"create\"]','succeeded',1,1,5,'2026-10-19 20:01:08','2026-10-20 20:01:08',NULL,NULL,NULL,'8d131ca0-9f8b-4d6b-9def-1c80a5540ad2',NULL,'eyJpdiI6ImRJbXhWVlY3TGhrV214M1gwT2gxdGc9PSIsInZhbHVlIjoiMDd1ZmM5VXpoNnBYRUFDVk9TLzJMT2trN3lxbzhlTGdzL1B6cFZmZGJiNG01b2dvNjZ4NDB1VERPOXkyWlhhVVJrTGNvWlQzemtnWUR5ZnhwODR0aExTVlo2djR3Y3dyNXpLcHJTcDU1VTBlYVNmcnhHbmh6UVVyZGFhQ1VvdG4iLCJtYWMiOiI4YWE3YTA4ODQxYjNlY2IyNjJiMGRjMzg1YmU0NTIxMTJhNmE5MDgzY2M5N2MwNzZhYjE1ZjQ2MzUyYTRiMGFkIiwidGFnIjoiIn0=','2026-10-19 20:01:08','2026-10-19 20:01:11'),('01a15778-5f10-7365-8f39-36f852bd7928','01a15778-5f0f-7233-8ec6-59408b08fe70','send','发送短信','demo.sms','{\"id\": \"sms.order.confirm\", \"name\": \"发送订单确认短信\", \"path\": \"/sms\", \"driver\": \"demo.sms.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true}, \"base_url\": \"http://127.0.0.1:9081\", \"operation\": \"order.confirm\", \"provider_id\": \"demo.sms\"}','{\"order_id\": \"$event.payload.order_id\"}','[]','succeeded',1,1,5,'2026-10-19 20:01:08','2026-10-20 20:01:08',NULL,NULL,NULL,'2db84ad0-7449-4302-a731-7ce855321b9a',NULL,'eyJpdiI6IjMzUGsyN0JlZVVPdGFZSDRlb1RPa0E9PSIsInZhbHVlIjoiWmJCMWNENXZnUWhtN1ZLSXZpQlA1UDd4RE9OZUVaQ1RUWFVtNUoveDM4UnhJaitneUltQmNvYktvT05LeGVQdGlsL2NiaFpSOFdwSTB1NGRvNUUvNkE9PSIsIm1hYyI6Ijg0MDlmNjg2NTQzY2VkZTQ2NTU5Njk4OWQzMGMzYzc5NDI3NDExODEwNzYxOTVmZTQ0ZTcxNzk5YWRhYjIyODAiLCJ0YWciOiIifQ==','2026-10-19 20:01:08','2026-10-19 20:01:10'),('01a15787-57fe-73a0-9e4c-07bfc113db72','01a15787-57f8-72d6-aa24-5acf365d5f28','reserve','预留库存','demo.inventory','{\"id\": \"inventory.reserve\", \"name\": \"预留库存\", \"path\": \"/reserve\", \"driver\": \"demo.inventory.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true}, \"base_url\": \"http://127.0.0.1:9081\", \"operation\": \"stock.reserve\", \"provider_id\": \"demo.inventory\"}','{\"order_id\": \"$event.payload.order_id\"}','[]','succeeded',1,1,5,'2026-10-19 20:17:30','2026-10-20 20:17:30',NULL,NULL,NULL,'ad8d4060-38fd-4920-a64c-62b9c3cbe6f4',NULL,'eyJpdiI6IkFnYkVCUm9CSVdtdllnb2hSSjM0bVE9PSIsInZhbHVlIjoiaTE2aUYzL2ZjaFZpb1JFSkxPaVdEcit0YkM1NSswa1ZEL0MyZXdUWDhtQWxMNS9lZVdqTURGdTBxWlBUYlgxUXdCSGRHR2luYUVlanc4MFVPWTNNK1E9PSIsIm1hYyI6IjQ2OGYwMjVlOTk4Zjk0ZDc1NDFlNjczZmQwYjEwMWUxODhmMmM3OTkzZjAxY2YyZWIzNjRmZTI1M2ZiZThjOWMiLCJ0YWciOiIifQ==','2026-10-19 20:17:30','2026-10-19 20:17:30'),('01a15787-5800-7116-a1e6-67656253b87e','01a15787-57ff-7397-947f-b715441261ac','create','创建联系人','demo.crm','{\"id\": \"crm.contact.create\", \"name\": \"创建联系人\", \"path\": \"/contacts\", \"driver\": \"demo.crm.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true}, \"base_url\": \"http://127.0.0.1:9081\", \"operation\": \"contact.create\", \"provider_id\": \"demo.crm\"}','{\"contact_id\": \"$event.payload.contact_id\"}','[]','succeeded',1,1,5,'2026-10-19 20:17:30','2026-10-20 20:17:30',NULL,NULL,NULL,'d9c6e704-03b4-408c-8793-f883bf3a88a9',NULL,'eyJpdiI6IkxtVHRiZW14QTQvWnJUTmwvNDlwUHc9PSIsInZhbHVlIjoiVnl6RnFwTGYzSGVidytzNmh4dmdZNm5tVDMxWit1c3RjK2Z6NlBKa0IwOVJNbDd0QUl6cmdjTGttd0VNc3E2MTAyRDJya1preGFUc2lGVTdTY3F1TUE9PSIsIm1hYyI6IjQ5ZjNlMzJjYTNjZmIzYzQ2ZWZhNDcwZTQ0OGZjZDRiYTE4ODU3Nzg4NTkyMzM5ODExMDgwYWRhZDA5ZjVmMzEiLCJ0YWciOiIifQ==','2026-10-19 20:17:30','2026-10-19 20:17:30'),('01a15787-5802-71d6-b9f9-d7afe350c04e','01a15787-57ff-7397-947f-b715441261ac','mark-paid','更新付费状态','demo.crm','{\"id\": \"crm.contact.paid\", \"name\": \"更新付费状态\", \"path\": \"/contacts/{contact_id}/paid\", \"driver\": \"demo.crm.v1\", \"method\": \"PATCH\", \"options\": {\"timeout\": 10, \"idempotent\": true}, \"base_url\": \"http://127.0.0.1:9081\", \"operation\": \"contact.mark-paid\", \"provider_id\": \"demo.crm\"}','{\"order_id\": \"$event.payload.order_id\", \"contact_id\": \"$steps.create.output.id\"}','[\"create\"]','succeeded',1,1,5,'2026-10-19 20:17:30','2026-10-20 20:17:30',NULL,NULL,NULL,'128a0e2b-6064-4f39-86a0-4c38fe04e839',NULL,'eyJpdiI6ImV4NytkVU1Id3dqbVpITXRnNVdSaXc9PSIsInZhbHVlIjoicUVQUGJvWlNxM1loWndVQnRabDNjbzc4U0RseTBGQlpmOXRQNUFLWFdCdFIzd21CRVVqTVErcU9Uem5UTFFDTFFna0R4TzNLTmZZVjNOLzRFUUVTTmFMWUVsWVZtdGNmdHN6cVNUQ0pHa2F6ckQ1K2RXaGVNQ1pyUDB0RTlBUFIiLCJtYWMiOiIxYWRmMTUwNmZkNTAwMGQ3ODljZjM0ZjI3YzlkOGEzM2EyM2Q5NDU1OGUwNGIxYTc5OGFmMzY4ZDJjNTI5ZTIwIiwidGFnIjoiIn0=','2026-10-19 20:17:30','2026-10-19 20:17:31'),('01a15787-5804-707f-8191-f189bcd47c1a','01a15787-5803-7109-a939-323fa94014d5','send','发送短信','demo.sms','{\"id\": \"sms.order.confirm\", \"name\": \"发送订单确认短信\", \"path\": \"/sms\", \"driver\": \"demo.sms.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true}, \"base_url\": \"http://127.0.0.1:9081\", \"operation\": \"order.confirm\", \"provider_id\": \"demo.sms\"}','{\"order_id\": \"$event.payload.order_id\"}','[]','succeeded',1,1,5,'2026-10-19 20:17:30','2026-10-20 20:17:30',NULL,NULL,NULL,'76b1d337-57a7-48ee-8569-8092c87fe8a3',NULL,'eyJpdiI6ImNHY0ZTeEN4aUVYUGRUN1dEd2ExZVE9PSIsInZhbHVlIjoidndEMDdWcHZOL3JyT3dZQmRIdlBhOGJDRWFRYjBNbGVzclVQQ2VVSXlWOExxZkIvZHdTSFZNU1BPTGgyakpwQ1FsbjlIbmpzajJOY3FXT05wdTBTb2c9PSIsIm1hYyI6ImRlNDZlN2RkYTZkYzJkYzU5YWVjYTU5NjY5NDg1MGNhZmNiNmFmMDZiZDc0YjI5MTI1NDlmYzdhNjhhM2UxYWUiLCJ0YWciOiIifQ==','2026-10-19 20:17:30','2026-10-19 20:17:31');
/*!40000 ALTER TABLE `request_steps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
INSERT INTO `sessions` VALUES ('epvqLdqNiY9UmMlG4mVRsoVz0eTY7SXraBFu1fCA',1,'127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','YTo2OntzOjY6Il90b2tlbiI7czo0MDoiQnN2QXBEZFNjaTFaVUhxRVJNYzZ1cUtqRnJMYVpVUlp2cFF2eDNnWSI7czozOiJ1cmwiO2E6MDp7fXM6OToiX3ByZXZpb3VzIjthOjI6e3M6MzoidXJsIjtzOjM4OiJodHRwOi8vbG9jYWxob3N0OjgwODgvd29ya2Zsb3dzL2NyZWF0ZSI7czo1OiJyb3V0ZSI7Tjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo1MDoibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiO2k6MTtzOjE3OiJwYXNzd29yZF9oYXNoX3dlYiI7czo2NDoiNjdlZjk1MTk1OTMzMGE0NzRhODM0YjgxZjFhYzkzZjliNTA5OTFmNmNhNjliYTI5NzY0ZjMyZWRkYjYxZDYyNSI7fQ==',1792466888),('qJAvChSrXNm8QMFd4S3Bxr3B1VYqfmacuT0c0jNu',1,'127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','YTo2OntzOjY6Il90b2tlbiI7czo0MDoiZjJTcG05WVpWMUxxNXVmUFpMaWhNM2lNWU9ZOVM3ZFNVOWtxN2RIaSI7czozOiJ1cmwiO2E6MDp7fXM6OToiX3ByZXZpb3VzIjthOjI6e3M6MzoidXJsIjtzOjI5OiJodHRwOi8vMTI3LjAuMC4xOjgwODgvc291cmNlcyI7czo1OiJyb3V0ZSI7Tjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo1MDoibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiO2k6MTtzOjE3OiJwYXNzd29yZF9oYXNoX3dlYiI7czo2NDoiNjdlZjk1MTk1OTMzMGE0NzRhODM0YjgxZjFhYzkzZjliNTA5OTFmNmNhNjliYTI5NzY0ZjMyZWRkYjYxZDYyNSI7fQ==',1792470033);
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'本地管理员','admin@localhost',NULL,'$2y$12$2DJhWrsLr9uYl.jSWRS9TulHIPvWBk5Ap/NuhIZE0Z4zLZt2iy9ce',NULL,'2026-10-19 10:56:39','2026-10-19 10:56:39');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workflow_versions`
--

DROP TABLE IF EXISTS `workflow_versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `workflow_versions` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `workflow_id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `number` int unsigned NOT NULL,
  `definition` json NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `workflow_versions_workflow_id_number_unique` (`workflow_id`,`number`),
  CONSTRAINT `workflow_versions_workflow_id_foreign` FOREIGN KEY (`workflow_id`) REFERENCES `workflows` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workflow_versions`
--

LOCK TABLES `workflow_versions` WRITE;
/*!40000 ALTER TABLE `workflow_versions` DISABLE KEYS */;
INSERT INTO `workflow_versions` VALUES ('01a15585-dd6b-7170-8bb2-e9a43fd12a3c','order.paid',1,'{\"tasks\": [{\"key\": \"inventory.reserve\", \"name\": \"预留订单库存\", \"steps\": [{\"key\": \"reserve\", \"name\": \"预留库存\", \"input\": {\"order_id\": \"$event.payload.order_id\"}, \"depends_on\": [], \"endpoint_id\": \"inventory.reserve\", \"endpoint_snapshot\": {\"id\": \"inventory.reserve\", \"name\": \"预留库存\", \"path\": \"/reserve\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.inventory\"}}], \"depends_on\": []}, {\"key\": \"crm.sync-paid\", \"name\": \"同步 CRM 付费状态\", \"steps\": [{\"key\": \"create\", \"name\": \"创建联系人\", \"input\": {\"contact_id\": \"$event.payload.contact_id\"}, \"depends_on\": [], \"endpoint_id\": \"crm.contact.create\", \"endpoint_snapshot\": {\"id\": \"crm.contact.create\", \"name\": \"创建联系人\", \"path\": \"/contacts\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.crm\"}}, {\"key\": \"mark-paid\", \"name\": \"更新付费状态\", \"input\": {\"order_id\": \"$event.payload.order_id\", \"contact_id\": \"$steps.create.output.id\"}, \"depends_on\": [\"create\"], \"endpoint_id\": \"crm.contact.paid\", \"endpoint_snapshot\": {\"id\": \"crm.contact.paid\", \"name\": \"更新付费状态\", \"path\": \"/paid\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.crm\"}}], \"depends_on\": []}, {\"key\": \"sms.confirm\", \"name\": \"发送订单确认短信\", \"steps\": [{\"key\": \"send\", \"name\": \"发送短信\", \"input\": {\"order_id\": \"$event.payload.order_id\"}, \"depends_on\": [], \"endpoint_id\": \"sms.order.confirm\", \"endpoint_snapshot\": {\"id\": \"sms.order.confirm\", \"name\": \"发送订单确认短信\", \"path\": \"/sms\", \"driver\": \"json-http.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true, \"success_codes\": [200, 201, 204]}, \"base_url\": \"http://127.0.0.1:9081\", \"provider_id\": \"demo.sms\"}}], \"depends_on\": [\"inventory.reserve\"]}]}','2026-10-19 10:56:38','2026-10-19 10:56:38'),('01a155a4-a7a6-721e-a2f4-325c4454c429','order.paid',2,'{\"tasks\": [{\"key\": \"inventory.reserve\", \"name\": \"预留订单库存\", \"steps\": [{\"key\": \"reserve\", \"name\": \"预留库存\", \"input\": {\"order_id\": \"$event.payload.order_id\"}, \"depends_on\": [], \"endpoint_id\": \"inventory.reserve\", \"endpoint_snapshot\": {\"id\": \"inventory.reserve\", \"name\": \"预留库存\", \"path\": \"/reserve\", \"driver\": \"demo.inventory.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true}, \"base_url\": \"http://127.0.0.1:9081\", \"operation\": \"stock.reserve\", \"provider_id\": \"demo.inventory\"}}], \"depends_on\": []}, {\"key\": \"crm.sync-paid\", \"name\": \"同步 CRM 付费状态\", \"steps\": [{\"key\": \"create\", \"name\": \"创建联系人\", \"input\": {\"contact_id\": \"$event.payload.contact_id\"}, \"depends_on\": [], \"endpoint_id\": \"crm.contact.create\", \"endpoint_snapshot\": {\"id\": \"crm.contact.create\", \"name\": \"创建联系人\", \"path\": \"/contacts\", \"driver\": \"demo.crm.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true}, \"base_url\": \"http://127.0.0.1:9081\", \"operation\": \"contact.create\", \"provider_id\": \"demo.crm\"}}, {\"key\": \"mark-paid\", \"name\": \"更新付费状态\", \"input\": {\"order_id\": \"$event.payload.order_id\", \"contact_id\": \"$steps.create.output.id\"}, \"depends_on\": [\"create\"], \"endpoint_id\": \"crm.contact.paid\", \"endpoint_snapshot\": {\"id\": \"crm.contact.paid\", \"name\": \"更新付费状态\", \"path\": \"/contacts/{contact_id}/paid\", \"driver\": \"demo.crm.v1\", \"method\": \"PATCH\", \"options\": {\"timeout\": 10, \"idempotent\": true}, \"base_url\": \"http://127.0.0.1:9081\", \"operation\": \"contact.mark-paid\", \"provider_id\": \"demo.crm\"}}], \"depends_on\": []}, {\"key\": \"sms.confirm\", \"name\": \"发送订单确认短信\", \"steps\": [{\"key\": \"send\", \"name\": \"发送短信\", \"input\": {\"order_id\": \"$event.payload.order_id\"}, \"depends_on\": [], \"endpoint_id\": \"sms.order.confirm\", \"endpoint_snapshot\": {\"id\": \"sms.order.confirm\", \"name\": \"发送订单确认短信\", \"path\": \"/sms\", \"driver\": \"demo.sms.v1\", \"method\": \"POST\", \"options\": {\"timeout\": 10, \"idempotent\": true}, \"base_url\": \"http://127.0.0.1:9081\", \"operation\": \"order.confirm\", \"provider_id\": \"demo.sms\"}}], \"depends_on\": [\"inventory.reserve\"]}]}','2026-10-19 11:30:16','2026-10-19 11:30:16');
/*!40000 ALTER TABLE `workflow_versions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workflows`
--

DROP TABLE IF EXISTS `workflows`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `workflows` (
  `id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `event_type` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `draft` json NOT NULL,
  `active_version_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `workflows_event_type_unique` (`event_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workflows`
--

LOCK TABLES `workflows` WRITE;
/*!40000 ALTER TABLE `workflows` DISABLE KEYS */;
INSERT INTO `workflows` VALUES ('order.paid','订单支付成功','order.paid.v1','{\"tasks\": [{\"key\": \"inventory.reserve\", \"name\": \"预留订单库存\", \"steps\": [{\"key\": \"reserve\", \"name\": \"预留库存\", \"input\": {\"order_id\": \"$event.payload.order_id\"}, \"depends_on\": [], \"endpoint_id\": \"inventory.reserve\"}], \"depends_on\": []}, {\"key\": \"crm.sync-paid\", \"name\": \"同步 CRM 付费状态\", \"steps\": [{\"key\": \"create\", \"name\": \"创建联系人\", \"input\": {\"contact_id\": \"$event.payload.contact_id\"}, \"depends_on\": [], \"endpoint_id\": \"crm.contact.create\"}, {\"key\": \"mark-paid\", \"name\": \"更新付费状态\", \"input\": {\"order_id\": \"$event.payload.order_id\", \"contact_id\": \"$steps.create.output.id\"}, \"depends_on\": [\"create\"], \"endpoint_id\": \"crm.contact.paid\"}], \"depends_on\": []}, {\"key\": \"sms.confirm\", \"name\": \"发送订单确认短信\", \"steps\": [{\"key\": \"send\", \"name\": \"发送短信\", \"input\": {\"order_id\": \"$event.payload.order_id\"}, \"depends_on\": [], \"endpoint_id\": \"sms.order.confirm\"}], \"depends_on\": [\"inventory.reserve\"]}]}','01a155a4-a7a6-721e-a2f4-325c4454c429',1,'2026-10-19 10:56:38','2026-10-19 11:30:16');
/*!40000 ALTER TABLE `workflows` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'notification_dispatcher'
--

--
-- Dumping routines for database 'notification_dispatcher'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-20 12:22:47
