//
//  InputAssociate.cpp
//  WeAblum
//
//  Created by chen liang on 2020/11/24.
//  Copyright © 2020 WeAblum. All rights reserved.
//

#include "InputAssociate.hpp"

class InputAssociate {
private:
    sql::Field id;
    sql::Field value;
    sql::Field relates;
    sql::Field prename;
public:
    InputAssociate():
        id(sql::Field("id", sql::type_int, sql::flag_primary_key)),
        value(sql::Field("word", sql::type_text)),
        relates(sql::Field("count", sql::type_text)),
        prename(sql::Field("prename", sql::type_text)) {
    }
    ~InputAssociate() {
    }
    
    sql::Field getId() {
        return this->id;
    }
    sql::Field getValue() {
        return this->value;
    }
    sql::Field getRelates() {
        return this->relates;
    }
    
    sql::FieldSet * associateFieldSet() {
        std::vector<sql::Field> fields;
        fields.push_back(this->id);
        fields.push_back(this->value);
        fields.push_back(this->relates);
        fields.push_back(this->prename);
        return new sql::FieldSet(fields);
    }
};

InputAssociateManager::InputAssociateManager() {
    this->db = new sql::Database();
}

InputAssociateManager::~InputAssociateManager() {
    close_db();
    delete this->db;
    delete this->table;
    delete this->jieba;
}

void InputAssociateManager::enable_db(std::string db_path) {
    this->db_path = db_path;
    try {
        this->db->open(db_path);
        InputAssociate associate = InputAssociate();
        sql::FieldSet *sets = associate.associateFieldSet();
        this->table = new sql::Table(this->db->getHandle(), "associate", sets);
        this->table->create();
        delete sets;
    } catch (sql::Exception e) {
        std::printf("ERROR:%s\r\n", e.msg().c_str());
    }
}

void InputAssociateManager::open_db() {
    this->db->open(this->db_path);
}

void InputAssociateManager::close_db() {
    this->db->close();
}

void InputAssociateManager::enable_jieba(std::string dict_path, std::string hmm_path, std::string user_dict_path, std::string idf_path, std::string stop_word_path, std::string dat_cache_path) {
    this->dict_pat = dict_path;
    this->hmm_path = hmm_path;
    this->user_dict_path = user_dict_path;
    this->idf_path = idf_path;
    this->stop_word_path = stop_word_path;
    this->jieba = new cppjieba::Jieba(dict_pat, hmm_path, user_dict_path, "", "", dat_cache_path);
}

std::vector<std::string>InputAssociateManager::get_associate_list(std::string input) {
    std::vector<std::string> values;
    std::string for_associate = get_input_last_word(input);
    std::string query_sql = get_select_sql(for_associate);
    this->table->query(query_sql);
    for (int i = 0; i < this->table->recordCount(); i++) {
        sql::Record record = this->table->getRecord(i);
        std::string value = record.getValue("word")->asString();
        std::vector<std::string> jieba_words = get_jieba_split_word(value);
        std::string associate = get_a_assoicate(for_associate, jieba_words);
        if (associate.size()) {
            if (std::find(values.begin(), values.end(), associate) == values.end()) {
                values.push_back(associate);
            }
        } else {
            auto res = get_a_assoicate(for_associate, value);
            if (res.size()) {
                if (std::find(values.begin(), values.end(), associate) == values.end()) {
                    values.push_back(res);
                }
            }
        }
    }
    return values;
}


std::vector<std::string>InputAssociateManager::get_split_list(std::string input) {
    std::vector<std::string> words;
    this->jieba->Cut(input, words);
    return words;
}
