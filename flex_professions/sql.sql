ALTER TABLE `players`
ADD COLUMN IF NOT EXISTS `professions` varchar(255) UNSIGNED DEFAULT NULL AFTER `last_logged_out`;