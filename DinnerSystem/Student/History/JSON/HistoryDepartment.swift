//
//	HistoryDepartment.swift
//
//	Create by Sean Pai on 6/1/2019
//	Copyright © 2019 New Taipei Municipal Banqiao Senior High School. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

struct HistoryDepartment : Codable {

	let factory : HistoryFactory?
	let id : String?
	let name : String?


	enum CodingKeys: String, CodingKey {
		case factory
		case id = "id"
		case name = "name"
	}
    init(factory : HistoryFactory? = nil,
         id : String? = nil,
         name : String? = nil
        ){
        self.factory = factory
        self.id = id
        self.name = name
    }



}
