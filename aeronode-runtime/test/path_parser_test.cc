/**
 * 
 * Copyright (c) 2018 南京航空航天大学 航空通信网络研究室
 * 
 * @file
 * @author   姜阳 (j824544269@gmail.com)
 * @date     2018-06
 * @brief    
 * @version  0.0.1
 * 
 * Last Modified:  2018-06-22
 * Modified By:    姜阳 (j824544269@gmail.com)
 * 
 */
#include "aeronode/path_parser.h"
#include "gtest/gtest.h"

namespace
{
TEST(PathParserTest, PathParserTest_First_Test)
{
    an::core::PathParser p("/first/second/third");
    EXPECT_STREQ("first", p.get_first().c_str());
    EXPECT_STREQ("second", p.get_second().c_str());
    EXPECT_STREQ("third", p.get_third().c_str());
}

TEST(PathParserTest, PathParserTest_Second_Test)
{
    an::core::PathParser p("/first/second/third");
    EXPECT_STREQ("first", p.get_first().c_str());
    EXPECT_STREQ("second", p.get_second().c_str());
    EXPECT_STREQ("third", p.get_third().c_str());
}
} // namespace