/////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2020, Codeoscopic S.A. - All Rights Reserved
//  Unauthorized copying of this file, via any medium is strictly prohibited
//  Proprietary and confidential
//
//  Copyright (C) 2020, Codeoscopic S.A. - Todos Los Derechos Reservados
//  La copia no autorizada de este archivo, a través de cualquier medio está estrictamente prohibida
//  Privado y confidencial
//
////////////////////////////////////////////////////////////////////////////////
package com.codeoscopic.avant.controllers
{
	import com.codeoscopic.avant.models.ProductCompaniesModel;
	import com.codeoscopic.avant.services.CompanyDelegate;
	import com.codeoscopic.avant.vos.Company;
	import com.codeoscopic.avant.vos.Product;

	import mx.rpc.events.ResultEvent;

	import org.apache.royale.collections.ArrayList;
	import org.apache.royale.collections.ArrayListView;
	import org.apache.royale.collections.Sort;
	import org.apache.royale.collections.SortField;
	import org.apache.royale.crux.utils.services.ServiceHelper;

	/**
     * The Todo Controller holds all the global actions. The views dispatch events that bubbles and
	 * this class register to these evens and updates the model, so views can update accordingly using
	 * binding most of the times.
     */
	public class CompanyController
	{
		/**
		 * Crux will automatically create any Bean for the built-in helper classes
		 * if one has not been defined.
		 */ 
		[Inject]
		public var serviceHelper:ServiceHelper;
		
        /**
		 *  Common todo model
		 */
		[Inject(source = "productCompaniesModel")]
		public var model:ProductCompaniesModel;
		
		[Inject]
		public var companyService:CompanyDelegate;

		[EventHandler(event="ProductCompaniesEvent.LOAD_COMPANIES")]
		public function loadCompanies():void
		{
			if(model.companies == null){
				model.selectedContent = "loader";//ProductCompaniesModel.LOADER_VIEW;
				serviceHelper.executeServiceCall(companyService.loadCompanies(), loadCompaniesResultHandler);
			} else {
				model.selectedContent = "companies";//ProductCompaniesModel.COMPANIES_VIEW;
			}
		}
		
		public function loadCompaniesResultHandler(event:ResultEvent):void {
			if(model.companies == null) {
				var data:Object = JSON.parse(event.result as String);
				processCompaniesData(data);
				model.selectedContent = "companies";//ProductCompaniesModel.COMPANIES_VIEW;
			}
		}

		public function processCompaniesData(data:Object):void
		{
			var sort:Sort = new Sort();
			sort.fields = [new SortField("name", true, false)];

			model.companies = new ArrayList();
			var company:Company;
			var product:Product;
			var products:Array;
			var products_wip:Array;
			for (var i:int = 0; i < data.length; i++) {
				// don't add this company if we don't have any product in it
				if(!data[i].products && !data[i].productswip)
					continue;
				company = new Company();
				company.id = data[i].id;
				company.name = data[i].companyname;
				// company.description = data[i].companydescription;
				company.logo = data[i].companylogo.guid.replace("avant2.es", "www.avant2.es");
				
				// add products
				products = data[i].products;
				company.products = new ArrayListView();
				for (var j:int = 0; j < products.length; j++) {
					product = new Product();
					product.id = products[j].ID;
					product.name = products[j].productname;
					product.image = products[j].productimage.guid;
					company.products.addItem(product);
				}
				// now go over products wip
				products = data[i].productswip;
				if(product)
				{
					for (j = 0; j < products.length; j++) {
						product = new Product();
						product.id = products[j].ID;
						product.name = products[j].productname;
						product.image = products[j].productimage.guid;
						product.wip = true;
						company.products.addItem(product);
					}
				}
				company.products.sort = sort;
				company.products.refresh();

				model.companies.addItem(company);
			}

			var alv:ArrayListView = new ArrayListView(model.companies);
			alv.sort = sort;
			alv.refresh();

			model.sortedCompanies = alv;
		}

		[EventHandler(event="ProductCompaniesEvent.GO_TO_GRID_VIEW")]
		public function goToGridView():void
		{
			if(model.companies == null){
				model.selectedContent = "loader";//ProductCompaniesModel.LOADER_VIEW;
				serviceHelper.executeServiceCall(companyService.loadCompanies(), goToGridViewResultHandler);
			} else {
				model.selectedContent = "gridview";//ProductCompaniesModel.COMPANIES_VIEW;
			}
		}

		public function goToGridViewResultHandler(event:ResultEvent):void {
			if(model.companies == null) {
				var data:Object = JSON.parse(event.result as String);
				processCompaniesData(data);
				model.selectedContent = "gridview";//ProductCompaniesModel.COMPANIES_VIEW;
			}
		}
	}
}
