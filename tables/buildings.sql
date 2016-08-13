-- phpMyAdmin SQL Dump
-- version 4.4.12
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Jul 28, 2015 at 04:09
-- Server version: 5.6.25
-- PHP Version: 5.6.11

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pcrpg`
--

-- --------------------------------------------------------

--
-- Table structure for table `buildings`
--

CREATE TABLE IF NOT EXISTS `buildings` (
  `ID` int(11) NOT NULL,
  `building_out_x` float DEFAULT NULL,
  `building_out_y` float DEFAULT NULL,
  `building_out_z` float DEFAULT NULL,
  `building_out_a` float DEFAULT NULL,
  `building_out_i` int(11) DEFAULT NULL,
  `building_out_v` int(11) DEFAULT NULL,
  `building_in_x` float DEFAULT NULL,
  `building_in_y` float DEFAULT NULL,
  `building_in_z` float DEFAULT NULL,
  `building_in_a` float DEFAULT NULL,
  `building_in_i` int(11) DEFAULT NULL,
  `building_in_v` int(11) DEFAULT NULL,
  `building_locked` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `buildings`
--

INSERT INTO `buildings` (`ID`, `building_out_x`, `building_out_y`, `building_out_z`, `building_out_a`, `building_out_i`, `building_out_v`, `building_in_x`, `building_in_y`, `building_in_z`, `building_in_a`, `building_in_i`, `building_in_v`, `building_locked`) VALUES
(1, 1555.08, -1675.65, 15.5, 95.637, 0, 0, 238.661, 138.691, 1002.5, 359.118, 3, 0, 0),
(2, 1480.9, -1771.29, 18.95, 3.996, 0, 0, 389.684, 173.675, 1007.8, 96.25, 3, 0, 0),
(3, 2229.57, -1721.52, 12.8, 132.266, 0, 0, 772.141, -4.392, 999.5, 9.506, 5, 0, 0),
(4, 1631.75, -1172.03, 23.4, 6.502, 0, 0, 834.203, 7.522, 1003.7, 89.34, 3, 0, 0),
(5, 2232.27, -1159.82, 25.19, 87.845, 0, 0, 2215.23, -1150.41, 1025.3, 276.944, 15, 0, 0),
(6, 1699.17, -1668.02, 19.5, 92.388, 0, 0, 1726.92, -1639.19, 19.8, 179.472, 18, 0, 0),
(7, -1603.45, -696.971, 1.2, 178.96, 0, 0, -1603.39, -695.328, 13.6, 0.145, 0, 0, 0),
(8, -1361.09, -697.026, 1.2, 180.658, 0, 0, -1361.12, -695.333, 13.6, 3.457, 0, 0, 0),
(9, -1154.19, -476.654, 1.2, 238.378, 0, 0, -1155.15, -476.197, 13.6, 55.292, 0, 0, 0),
(10, -1081.63, -207.85, 1.2, 300.007, 0, 0, -1083.26, -208.523, 13.6, 118.988, 0, 0, 0),
(11, -1182.59, 60.381, 1.2, 315.57, 0, 0, -1183.52, 59.589, 13.6, 135.042, 0, 0, 0),
(12, -1115.67, 334.999, 1.2, 217.313, 0, 0, -1116.46, 336.014, 13.6, 41.406, 0, 0, 0),
(13, -1164.81, 370.212, 1.2, 42.069, 0, 0, -1163.75, 369.155, 13.6, 224.26, 0, 0, 0),
(14, -1444.44, 90.253, 1.2, 41.86, 0, 0, -1443.72, 89.423, 13.6, 221.561, 0, 0, 0),
(15, -1618.79, -84.056, 1.2, 42.355, 0, 0, -1617.85, -84.898, 13.6, 223.433, 0, 0, 0),
(16, -1736.87, -445.912, 1.2, 87.08, 0, 0, -1734.97, -445.99, 13.6, 272.816, 0, 0, 0),
(17, 1571.29, -1336.76, 15.7, 317.234, 0, 0, 1548.68, -1364.2, 325.8, 182.609, 0, 0, 0),
(18, 914.466, -1004.23, 37.2, 1.379, 0, 0, 1591.41, -1034.93, 23.3, 273.491, 1, 17, 0),
(19, 953.813, -1336.56, 12.8, 1.774, 0, 0, -100.396, -25.031, 1000.2, 3.38, 3, 0, 0),
(20, 2421.54, -1219.52, 24.8, 185.999, 0, 0, 1204.67, -13.543, 1000.4, 350.02, 2, 0, 0),
(21, 2068.9, -1779.84, 12.8, 273.744, 0, 0, -204.447, -27.17, 1001.8, 3.631, 16, 0, 0),
(22, 2071, -1793.85, 12.8, 270.438, 0, 0, 418.75, -84.032, 1001.2, 359.52, 3, 0, 0),
(23, 1940.19, -2115.98, 13, 267.109, 0, 0, -100.396, -25.031, 1000.2, 3.38, 3, 1, 0),
(24, 2657.7, -1588.84, 13.205, 186.08, 0, 0, -959.668, 1956.26, 8.5, 181.145, 17, 0, 0),
(25, 2353.09, -1463.49, 23.3, 96.962, 0, 0, -100.396, -25.031, 1000.3, 3.38, 3, 2, 0),
(26, 1310.11, -1367.23, 13, 184.686, 0, 0, -2026.89, -104.129, 1034.6, 182.764, 3, 0, 0),
(27, 1658.1, -1343.33, 16.9, 86.284, 0, 0, 366.698, 197.228, 1007.8, 1.7, 3, 1, 0),
(28, 850.919, -1587.45, 13, 228.357, 0, 0, -2240.62, 137.119, 1034.9, 273.643, 6, 0, 0),
(29, 823.961, -1588.24, 13, 137.208, 0, 0, 412.007, -54.441, 1001.4, 6.97, 12, 0, 0);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `buildings`
--
ALTER TABLE `buildings`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `ID` (`ID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `buildings`
--
ALTER TABLE `buildings`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=30;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
