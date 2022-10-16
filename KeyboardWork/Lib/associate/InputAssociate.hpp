//
//  InputAssociate.hpp
//  WeAblum
//
//  Created by chen liang on 2020/11/24.
//  Copyright © 2020 WeAblum. All rights reserved.
//

#ifndef InputAssociate_hpp
#define InputAssociate_hpp

#include <stdio.h>
#include <regex>
#include "SqlTable.h"
#include "SqlDatabase.h"
#include "SqlCommon.h"
#include "Jieba.hpp"

class InputAssociateManager {
    
private:
    sql::Database *db;
    sql::Table *table;
    cppjieba::Jieba *jieba;
    std::string dict_pat;
    std::string hmm_path;
    std::string user_dict_path;
    std::string idf_path;
    std::string stop_word_path;
    std::string db_path;
    
public:
    InputAssociateManager(void);
    ~InputAssociateManager();
    void enable_db(std::string db_path);
    void enable_jieba(std::string dict_path, std::string hmm_path, std::string user_dict_path, std::string idf_path, std::string stop_word_path,std::string dat_cache_path);
    std::vector<std::string> get_associate_list(std::string input);
    std::vector<std::string> get_split_list(std::string input);
    //前后台切换的时候可以调用
    void open_db();
    void close_db();
private:
    
    std::vector<std::string> get_jieba_split_word(const std::string &word) {
        std::vector<std::string> words;
        this->jieba->Cut(word, words);
        return words;
    }
    
    std::string get_input_last_word(std::string &word) {
        return get_jieba_split_word(word).back();
    }
    
    std::string get_select_sql(std::string &word) {
        std::ostringstream os;
        os << "select * from assoicate where word like '" << word << "%' and prename = '" << word.substr(0,3) << "' and count >= 100 order by count desc limit 50";
//        std::cout << os.str();
        std::string sql = os.str();
        return sql;
    }
    
    std::string get_a_assoicate(std::string &assoicate, std::vector<std::string> &words) {
        std::string res = "";
        for (int i = 0; i < words.size(); i++) {
            std::ostringstream os;
            os << assoicate << "(.*)";
            std::string regex_str = os.str();
            std::regex regx(regex_str);
            std::smatch m;
            if(std::regex_search(words[i], m, regx)) {
                std::string value = m[1].str();
                if (value.size() > 0) {
                    res = value;
                } else {
                    if (i != (words.size() - 1)) {
                        res = words[i+1];
                    }
                }
                return res;
            }
        }
        return res;
    }
    
    std::string get_a_assoicate(std::string &assoicate, std::string &value) {
        std::ostringstream os;
        std::string res = "";
        os << assoicate << "(.*)";
        std::string regex_str = os.str();
        std::regex regx(regex_str);
        std::smatch m;
        if(std::regex_search(value, m, regx)) {
            std::string value = m[1].str();
            if (value.size() > 0) {
                res = value;
            }
        }
        return res;
    }
};

#endif /* InputAssociate_hpp */
