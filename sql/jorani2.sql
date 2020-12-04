-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : jeu. 03 déc. 2020 à 10:49
-- Version du serveur :  10.4.14-MariaDB
-- Version de PHP : 7.4.9

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `jorani`
--

DELIMITER $$
--
-- Fonctions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `GetAcronym` (`str` TEXT) RETURNS TEXT CHARSET utf8 READS SQL DATA
    SQL SECURITY INVOKER
BEGIN
    declare result text default '';
    set result = GetInitials( str, '[[:alnum:]]' );
    return result;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `GetAncestry` (`GivenID` INT) RETURNS VARCHAR(1024) CHARSET utf8 READS SQL DATA
    SQL SECURITY INVOKER
BEGIN
    DECLARE rv VARCHAR(1024);
    DECLARE cm CHAR(1);
    DECLARE ch INT;

    SET rv = '';
    SET cm = '';
    SET ch = GivenID;
    WHILE ch > 0 DO
        SELECT IFNULL(parent_id,-1) INTO ch FROM
        (SELECT parent_id FROM organization WHERE id = ch) A;
        IF ch > 0 THEN
            SET rv = CONCAT(rv,cm,ch);
            SET cm = ',';
        END IF;
    END WHILE;
    RETURN rv;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `GetFamilyTree` (`GivenID` INT) RETURNS VARCHAR(1024) CHARSET utf8 READS SQL DATA
    SQL SECURITY INVOKER
BEGIN

    DECLARE rv,q,queue,queue_children VARCHAR(1024);
    DECLARE queue_length,front_id,pos INT;

    SET rv = '';
    SET queue = GivenID;
    SET queue_length = 1;

    WHILE queue_length > 0 DO
        IF queue_length = 1 THEN
            SET front_id = CAST(queue AS INT);
            SET queue = '';
        ELSE
            SET pos = LOCATE(',',queue);
            SET front_id = CAST(SUBSTR(queue, 1, pos-1) AS INT);
            SET q = SUBSTR(queue,pos + 1); 
            SET queue = q;
        END IF;
        SET queue_length = queue_length - 1;

        SELECT IFNULL(qc,'') INTO queue_children
        FROM (SELECT GROUP_CONCAT(id) qc
        FROM organization WHERE parent_id = front_id) A;

        IF LENGTH(queue_children) = 0 THEN
            IF LENGTH(queue) = 0 THEN
                SET queue_length = 0;
            END IF;
        ELSE
            IF LENGTH(rv) = 0 THEN
                SET rv = queue_children;
            ELSE
                SET rv = CONCAT(rv,',',queue_children);
            END IF;
            IF LENGTH(queue) = 0 THEN
                SET queue = queue_children;
            ELSE
                SET queue = CONCAT(queue,',',queue_children);
            END IF;
            SET queue_length = LENGTH(queue) - LENGTH(REPLACE(queue,',','')) + 1;
        END IF;
    END WHILE;
    RETURN rv;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `GetInitials` (`str` TEXT, `expr` TEXT) RETURNS TEXT CHARSET utf8 READS SQL DATA
    SQL SECURITY INVOKER
BEGIN
    declare result text default '';
    declare buffer text default '';
    declare i int default 1;
    if(str is null) then
        return null;
    end if;
    set buffer = trim(str);
    while i <= length(buffer) do
        if substr(buffer, i, 1) regexp expr then
            set result = concat( result, substr( buffer, i, 1 ));
            set i = i + 1;
            while i <= length( buffer ) and substr(buffer, i, 1) regexp expr do
                set i = i + 1;
            end while;
            while i <= length( buffer ) and substr(buffer, i, 1) not regexp expr do
                set i = i + 1;
            end while;
        else
            set i = i + 1;
        end if;
    end while;
    return result;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `GetParentIDByID` (`GivenID` INT) RETURNS INT(11) READS SQL DATA
    SQL SECURITY INVOKER
BEGIN
    DECLARE rv INT;

    SELECT IFNULL(parent_id,-1) INTO rv FROM
    (SELECT parent_id FROM organization WHERE id = GivenID) A;
    RETURN rv;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `actions`
--

CREATE TABLE `actions` (
  `name` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `mask` bit(16) NOT NULL,
  `Description` text COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='List of possible actions';

--
-- Déchargement des données de la table `actions`
--

INSERT INTO `actions` (`name`, `mask`, `Description`) VALUES
('accept_requests', b'0011000100110010', 'Accept the request of my team members'),
('admin_menu', b'0011000100110010', 'View admin menu'),
('change_password', b'0011000100110010', 'Change password'),
('create_leaves', b'0011000100110010', 'Create a new user leave request'),
('create_user', b'0011000100110010', 'Create a new user'),
('delete_user', b'0011000100110010', 'Delete an existing user'),
('edit_leaves', b'0011000100110010', 'Edit a leave request'),
('edit_settings', b'0011000100110010', 'Edit application settings'),
('edit_user', b'0011000100110010', 'Edit a user'),
('export_leaves', b'0011000100110010', 'Export the list of leave requests into an Excel file'),
('export_user', b'0011000100110010', 'Export the list of users into an Excel file'),
('hr_menu', b'0011000100110010', 'View HR menu'),
('individual_calendar', b'0011000100110010', 'View my leaves in a calendar'),
('list_leaves', b'0011000100110010', 'List my leave requests'),
('list_requests', b'0011000100110010', 'List the request of my team members'),
('list_users', b'0011000100110010', 'List users'),
('reject_requests', b'0011000100110010', 'Reject the request of my team members'),
('reset_password', b'0011000100110010', 'Modifiy the password of another user'),
('team_calendar', b'0011000100110010', 'View the leaves of my team in a calendar'),
('update_user', b'0011000100110010', 'Update a user'),
('view_leaves', b'0011000100110010', 'View the details of a leave request'),
('view_user', b'0011000100110010', 'View user\'s details');

-- --------------------------------------------------------

--
-- Structure de la table `ci_sessions`
--

CREATE TABLE `ci_sessions` (
  `id` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `timestamp` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `data` blob NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='CodeIgniter sessions (you can empty this table without consequence)';

-- --------------------------------------------------------

--
-- Structure de la table `contracts`
--

CREATE TABLE `contracts` (
  `id` int(11) NOT NULL COMMENT 'Unique identifier of a contract',
  `name` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Name of the contract',
  `startentdate` varchar(5) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Day and month numbers of the left boundary',
  `endentdate` varchar(5) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Day and month numbers of the right boundary',
  `weekly_duration` int(11) DEFAULT NULL COMMENT 'Approximate duration of work per week (in minutes)',
  `daily_duration` int(11) DEFAULT NULL COMMENT 'Approximate duration of work per day and (in minutes)',
  `default_leave_type` int(11) DEFAULT NULL COMMENT 'default leave type for the contract (overwrite default type set in config file).'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='A contract groups employees having the same days off and entitlement rules';

--
-- Déchargement des données de la table `contracts`
--

INSERT INTO `contracts` (`id`, `name`, `startentdate`, `endentdate`, `weekly_duration`, `daily_duration`, `default_leave_type`) VALUES
(1, 'Global', '01/01', '12/31', 2400, 480, 1);

-- --------------------------------------------------------

--
-- Structure de la table `dayoffs`
--

CREATE TABLE `dayoffs` (
  `id` int(11) NOT NULL,
  `contract` int(11) NOT NULL COMMENT 'Contract id',
  `date` date NOT NULL COMMENT 'Date of the day off',
  `type` int(11) NOT NULL COMMENT 'Half or full day',
  `title` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Description of day off'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='List of non working days';

-- --------------------------------------------------------

--
-- Structure de la table `delegations`
--

CREATE TABLE `delegations` (
  `id` int(11) NOT NULL COMMENT 'Id of delegation',
  `manager_id` int(11) NOT NULL COMMENT 'Manager wanting to delegate',
  `delegate_id` int(11) NOT NULL COMMENT 'Employee having the delegation'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Delegation of approval';

-- --------------------------------------------------------

--
-- Structure de la table `entitleddays`
--

CREATE TABLE `entitleddays` (
  `id` int(11) NOT NULL COMMENT 'Unique identifier of an entitlement',
  `contract` int(11) DEFAULT NULL COMMENT 'If entitlement is credited to a contract, Id of contract',
  `employee` int(11) DEFAULT NULL COMMENT 'If entitlement is credited to an employee, Id of employee',
  `overtime` int(11) DEFAULT NULL COMMENT 'Optional Link to an overtime request, if the credit is due to an OT',
  `startdate` date DEFAULT NULL COMMENT 'Left boundary of the credit validity',
  `enddate` date DEFAULT NULL COMMENT 'Right boundary of the credit validity. Duration cannot exceed one year',
  `type` int(11) NOT NULL COMMENT 'Leave type',
  `days` decimal(10,2) NOT NULL COMMENT 'Number of days (can be negative so as to deduct/adjust entitlement)',
  `description` text COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Description of a credit / debit (entitlement / adjustment)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Add or substract entitlement on employees or contracts (can be the result of an OT)';

-- --------------------------------------------------------

--
-- Structure de la table `excluded_types`
--

CREATE TABLE `excluded_types` (
  `id` int(11) NOT NULL COMMENT 'Id of exclusion',
  `contract_id` int(11) NOT NULL COMMENT 'Id of contract',
  `type_id` int(11) NOT NULL COMMENT 'Id of leave ype to be excluded to the contract'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Exclude a leave type from a contract';

-- --------------------------------------------------------

--
-- Structure de la table `leaves`
--

CREATE TABLE `leaves` (
  `id` int(11) NOT NULL COMMENT 'Unique identifier of the leave request',
  `startdate` date DEFAULT NULL COMMENT 'Start date of the leave request',
  `enddate` date DEFAULT NULL COMMENT 'End date of the leave request',
  `status` int(11) DEFAULT NULL COMMENT 'Identifier of the status of the leave request (Requested, Accepted, etc.). See status table.',
  `employee` int(11) DEFAULT NULL COMMENT 'Employee requesting the leave request',
  `cause` text COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Reason of the leave request',
  `startdatetype` varchar(12) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Morning/Afternoon',
  `enddatetype` varchar(12) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Morning/Afternoon',
  `duration` decimal(10,3) DEFAULT NULL COMMENT 'Length of the leave request',
  `type` int(11) DEFAULT NULL COMMENT 'Identifier of the type of the leave request (Paid, Sick, etc.). See type table.',
  `comments` text COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Comments on leave request (JSon)',
  `document` blob DEFAULT NULL COMMENT 'Optional supporting document'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Leave requests';

-- --------------------------------------------------------

--
-- Structure de la table `leaves_history`
--

CREATE TABLE `leaves_history` (
  `id` int(11) NOT NULL,
  `startdate` date DEFAULT NULL,
  `enddate` date DEFAULT NULL,
  `status` int(11) DEFAULT NULL,
  `employee` int(11) DEFAULT NULL,
  `cause` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `startdatetype` varchar(12) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `enddatetype` varchar(12) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `duration` decimal(10,2) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `comments` text COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Comments on leave request',
  `document` blob DEFAULT NULL COMMENT 'Optional supporting document',
  `change_id` int(11) NOT NULL,
  `change_type` int(11) NOT NULL,
  `changed_by` int(11) NOT NULL,
  `change_date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='List of changes in leave requests table';

-- --------------------------------------------------------

--
-- Structure de la table `oauth_access_tokens`
--

CREATE TABLE `oauth_access_tokens` (
  `access_token` varchar(40) NOT NULL,
  `client_id` varchar(80) NOT NULL,
  `user_id` varchar(255) DEFAULT NULL,
  `expires` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `scope` varchar(2000) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `oauth_applications`
--

CREATE TABLE `oauth_applications` (
  `user` int(11) NOT NULL COMMENT 'Identifier of Jorani user',
  `client_id` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Identifier of an application using OAuth2'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='List of allowed OAuth2 applications';

-- --------------------------------------------------------

--
-- Structure de la table `oauth_authorization_codes`
--

CREATE TABLE `oauth_authorization_codes` (
  `authorization_code` varchar(40) NOT NULL,
  `client_id` varchar(80) NOT NULL,
  `user_id` varchar(255) DEFAULT NULL,
  `redirect_uri` varchar(2000) DEFAULT NULL,
  `expires` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `scope` varchar(2000) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `oauth_clients`
--

CREATE TABLE `oauth_clients` (
  `client_id` varchar(80) NOT NULL,
  `client_secret` varchar(80) DEFAULT NULL,
  `redirect_uri` varchar(2000) NOT NULL,
  `grant_types` varchar(80) DEFAULT NULL,
  `scope` varchar(100) DEFAULT NULL,
  `user_id` varchar(80) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `oauth_jwt`
--

CREATE TABLE `oauth_jwt` (
  `client_id` varchar(80) NOT NULL,
  `subject` varchar(80) DEFAULT NULL,
  `public_key` varchar(2000) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `oauth_refresh_tokens`
--

CREATE TABLE `oauth_refresh_tokens` (
  `refresh_token` varchar(40) NOT NULL,
  `client_id` varchar(80) NOT NULL,
  `user_id` varchar(255) DEFAULT NULL,
  `expires` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `scope` varchar(2000) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `oauth_scopes`
--

CREATE TABLE `oauth_scopes` (
  `scope` text DEFAULT NULL,
  `is_default` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `oauth_users`
--

CREATE TABLE `oauth_users` (
  `username` varchar(255) NOT NULL,
  `password` varchar(2000) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `organization`
--

CREATE TABLE `organization` (
  `id` int(11) NOT NULL COMMENT 'Unique identifier of the department',
  `name` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Name of the department',
  `parent_id` int(11) DEFAULT NULL COMMENT 'Parent department (or -1 if root)',
  `supervisor` int(11) DEFAULT NULL COMMENT 'This user will receive a copy of accepted and rejected leave requests'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tree of the organization';

--
-- Déchargement des données de la table `organization`
--

INSERT INTO `organization` (`id`, `name`, `parent_id`, `supervisor`) VALUES
(0, 'LMS root', -1, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `org_lists`
--

CREATE TABLE `org_lists` (
  `id` int(11) NOT NULL COMMENT 'Unique identifier of a list',
  `user` int(11) NOT NULL COMMENT ' Identifier of Jorani user owning the list',
  `name` varchar(512) COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Custom lists of employees are an alternative to organization';

-- --------------------------------------------------------

--
-- Structure de la table `org_lists_employees`
--

CREATE TABLE `org_lists_employees` (
  `list` int(11) NOT NULL COMMENT 'Id of the list',
  `user` int(11) NOT NULL COMMENT 'id of an employee',
  `orderlist` int(11) NOT NULL COMMENT 'order in the list'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Children table of org_lists (custom list of employees)';

-- --------------------------------------------------------

--
-- Structure de la table `overtime`
--

CREATE TABLE `overtime` (
  `id` int(11) NOT NULL COMMENT 'Unique identifier of the overtime request',
  `employee` int(11) NOT NULL COMMENT 'Employee requesting the OT',
  `date` date NOT NULL COMMENT 'Date when the OT was done',
  `duration` decimal(10,3) NOT NULL COMMENT 'Duration of the OT',
  `cause` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Reason why the OT was done',
  `status` int(11) NOT NULL COMMENT 'Status of OT (Planned, Requested, Accepted, Rejected)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Overtime worked (extra time)';

-- --------------------------------------------------------

--
-- Structure de la table `parameters`
--

CREATE TABLE `parameters` (
  `name` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `scope` int(11) NOT NULL COMMENT 'Either global(0) or user(1) scope',
  `value` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'PHP/serialize value',
  `entity_id` text COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Entity ID (eg. user id) to which the parameter is applied'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Application parameters';

-- --------------------------------------------------------

--
-- Structure de la table `positions`
--

CREATE TABLE `positions` (
  `id` int(11) NOT NULL COMMENT 'Unique identifier of the position',
  `name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Name of the position',
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Description of the position'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Position (job position) in the organization';

--
-- Déchargement des données de la table `positions`
--

INSERT INTO `positions` (`id`, `name`, `description`) VALUES
(1, 'Employee', 'Employee.');

-- --------------------------------------------------------

--
-- Structure de la table `roles`
--

CREATE TABLE `roles` (
  `id` int(11) NOT NULL,
  `name` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Roles in the application (system table)';

--
-- Déchargement des données de la table `roles`
--

INSERT INTO `roles` (`id`, `name`) VALUES
(1, 'admin'),
(2, 'user'),
(8, 'HR admin');

-- --------------------------------------------------------

--
-- Structure de la table `status`
--

CREATE TABLE `status` (
  `id` int(11) NOT NULL,
  `name` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Status of the Leave Request (system table)';

--
-- Déchargement des données de la table `status`
--

INSERT INTO `status` (`id`, `name`) VALUES
(1, 'Planned'),
(2, 'Requested'),
(3, 'Accepted'),
(4, 'Rejected'),
(5, 'Cancellation'),
(6, 'Canceled');

-- --------------------------------------------------------

--
-- Structure de la table `types`
--

CREATE TABLE `types` (
  `id` int(11) NOT NULL COMMENT 'Unique identifier of the type',
  `name` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Name of the leave type',
  `acronym` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Acronym of the leave type',
  `deduct_days_off` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Deduct days off when computing the balance of the leave type'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='List of leave types (LoV table)';

--
-- Déchargement des données de la table `types`
--

INSERT INTO `types` (`id`, `name`, `acronym`, `deduct_days_off`) VALUES
(0, 'compensate', NULL, 0),
(1, 'paid leave', NULL, 0),
(2, 'maternity leave', NULL, 0),
(3, 'paternity leave', NULL, 0),
(4, 'special leave', NULL, 0),
(5, 'Sick leave', NULL, 0);

-- --------------------------------------------------------

--
-- Structure de la table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL COMMENT 'Unique identifier of the user',
  `firstname` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'First name',
  `lastname` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Last name',
  `login` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Identfier used to login (can be an email address)',
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Email address',
  `password` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Password encrypted with BCRYPT or a similar method',
  `role` int(11) DEFAULT NULL COMMENT 'Role of the employee (binary mask). See table roles.',
  `manager` int(11) DEFAULT NULL COMMENT 'Employee validating the requests of the employee',
  `country` int(11) DEFAULT NULL COMMENT 'Country code (for later use)',
  `organization` int(11) DEFAULT 0 COMMENT 'Entity where the employee has a position',
  `contract` int(11) DEFAULT NULL COMMENT 'Contract of the employee',
  `position` int(11) DEFAULT NULL COMMENT 'Position of the employee',
  `datehired` date DEFAULT NULL COMMENT 'Date hired / Started',
  `identifier` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Internal/company identifier',
  `language` varchar(5) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'en' COMMENT 'Language ISO code',
  `ldap_path` varchar(1024) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'LDAP Path for complex authentication schemes',
  `active` tinyint(1) DEFAULT 1 COMMENT 'Is user active',
  `timezone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Timezone of user',
  `calendar` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'External Calendar address',
  `random_hash` varchar(24) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Obfuscate public URLs',
  `user_properties` text COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Entity ID (eg. user id) to which the parameter is applied',
  `picture` blob DEFAULT NULL COMMENT 'Profile picture of user for tabular calendar'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='List of employees / users having access to Jorani';

--
-- Déchargement des données de la table `users`
--

INSERT INTO `users` (`id`, `firstname`, `lastname`, `login`, `email`, `password`, `role`, `manager`, `country`, `organization`, `contract`, `position`, `datehired`, `identifier`, `language`, `ldap_path`, `active`, `timezone`, `calendar`, `random_hash`, `user_properties`, `picture`) VALUES
(1, 'Benjamin', 'BALET', 'bbalet', 'benjamin.balet@gmail.com', '$2a$08$LeUbaGFqJjLSAN7to9URsuHB41zcmsMBgBhpZuFp2y2OTxtVcMQ.C', 8, 1, NULL, 0, 1, 1, '2013-10-28', 'PNC0025', 'en', NULL, 1, NULL, NULL, '5g5VUm5ZKf5TkK08yMtuKxe5', NULL, NULL);

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `actions`
--
ALTER TABLE `actions`
  ADD PRIMARY KEY (`name`);

--
-- Index pour la table `ci_sessions`
--
ALTER TABLE `ci_sessions`
  ADD KEY `ci_sessions_timestamp` (`timestamp`);

--
-- Index pour la table `contracts`
--
ALTER TABLE `contracts`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `dayoffs`
--
ALTER TABLE `dayoffs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `type` (`type`),
  ADD KEY `contract` (`contract`);

--
-- Index pour la table `delegations`
--
ALTER TABLE `delegations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `manager_id` (`manager_id`);

--
-- Index pour la table `entitleddays`
--
ALTER TABLE `entitleddays`
  ADD PRIMARY KEY (`id`),
  ADD KEY `contract` (`contract`),
  ADD KEY `employee` (`employee`),
  ADD KEY `type` (`type`);

--
-- Index pour la table `excluded_types`
--
ALTER TABLE `excluded_types`
  ADD PRIMARY KEY (`id`),
  ADD KEY `contract_id` (`contract_id`);

--
-- Index pour la table `leaves`
--
ALTER TABLE `leaves`
  ADD PRIMARY KEY (`id`),
  ADD KEY `status` (`status`),
  ADD KEY `employee` (`employee`);

--
-- Index pour la table `leaves_history`
--
ALTER TABLE `leaves_history`
  ADD PRIMARY KEY (`change_id`),
  ADD KEY `changed_by` (`changed_by`),
  ADD KEY `change_date` (`change_date`);

--
-- Index pour la table `oauth_access_tokens`
--
ALTER TABLE `oauth_access_tokens`
  ADD PRIMARY KEY (`access_token`);

--
-- Index pour la table `oauth_applications`
--
ALTER TABLE `oauth_applications`
  ADD KEY `user` (`user`),
  ADD KEY `client_id` (`client_id`);

--
-- Index pour la table `oauth_authorization_codes`
--
ALTER TABLE `oauth_authorization_codes`
  ADD PRIMARY KEY (`authorization_code`);

--
-- Index pour la table `oauth_clients`
--
ALTER TABLE `oauth_clients`
  ADD PRIMARY KEY (`client_id`);

--
-- Index pour la table `oauth_jwt`
--
ALTER TABLE `oauth_jwt`
  ADD PRIMARY KEY (`client_id`);

--
-- Index pour la table `oauth_refresh_tokens`
--
ALTER TABLE `oauth_refresh_tokens`
  ADD PRIMARY KEY (`refresh_token`);

--
-- Index pour la table `oauth_users`
--
ALTER TABLE `oauth_users`
  ADD PRIMARY KEY (`username`);

--
-- Index pour la table `organization`
--
ALTER TABLE `organization`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `org_lists`
--
ALTER TABLE `org_lists`
  ADD PRIMARY KEY (`id`),
  ADD KEY `org_lists_user` (`user`);

--
-- Index pour la table `org_lists_employees`
--
ALTER TABLE `org_lists_employees`
  ADD KEY `org_list_id` (`list`);

--
-- Index pour la table `overtime`
--
ALTER TABLE `overtime`
  ADD PRIMARY KEY (`id`),
  ADD KEY `status` (`status`),
  ADD KEY `employee` (`employee`);

--
-- Index pour la table `parameters`
--
ALTER TABLE `parameters`
  ADD KEY `param_name` (`name`,`scope`);

--
-- Index pour la table `positions`
--
ALTER TABLE `positions`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `status`
--
ALTER TABLE `status`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `types`
--
ALTER TABLE `types`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD KEY `manager` (`manager`),
  ADD KEY `organization` (`organization`),
  ADD KEY `contract` (`contract`),
  ADD KEY `position` (`position`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `contracts`
--
ALTER TABLE `contracts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier of a contract', AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `dayoffs`
--
ALTER TABLE `dayoffs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `delegations`
--
ALTER TABLE `delegations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Id of delegation';

--
-- AUTO_INCREMENT pour la table `entitleddays`
--
ALTER TABLE `entitleddays`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier of an entitlement';

--
-- AUTO_INCREMENT pour la table `excluded_types`
--
ALTER TABLE `excluded_types`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Id of exclusion';

--
-- AUTO_INCREMENT pour la table `leaves`
--
ALTER TABLE `leaves`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier of the leave request';

--
-- AUTO_INCREMENT pour la table `leaves_history`
--
ALTER TABLE `leaves_history`
  MODIFY `change_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `organization`
--
ALTER TABLE `organization`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier of the department';

--
-- AUTO_INCREMENT pour la table `org_lists`
--
ALTER TABLE `org_lists`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier of a list';

--
-- AUTO_INCREMENT pour la table `overtime`
--
ALTER TABLE `overtime`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier of the overtime request';

--
-- AUTO_INCREMENT pour la table `positions`
--
ALTER TABLE `positions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier of the position', AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `types`
--
ALTER TABLE `types`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier of the type', AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT pour la table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier of the user', AUTO_INCREMENT=2;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
