﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	Если ТекущийОбъект.ТипДанных = Перечисления.ТипыДанныхКэшаПрограммныхИнтерфейсов.ВерсииИнтерфейса Тогда
		
		Данные = ТекущийОбъект.Данные.Получить();
		Тело = ОбщегоНазначения.ЗначениеВСтрокуXML(Данные);
		
	ИначеЕсли ТекущийОбъект.ТипДанных = Перечисления.ТипыДанныхКэшаПрограммныхИнтерфейсов.ОписаниеWebСервиса Тогда
		
		ВременныйФайл = ПолучитьИмяВременногоФайла("xml");
		
		ДвоичныеДанные = ТекущийОбъект.Данные.Получить(); // ДвоичныеДанные - 
		ДвоичныеДанные.Записать(ВременныйФайл);
		
		ТекстовыйДокумент = Новый ТекстовыйДокумент();
		ТекстовыйДокумент.Прочитать(ВременныйФайл);
		
		Тело = ТекстовыйДокумент.ПолучитьТекст();
		
		УдалитьФайлы(ВременныйФайл);
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	Если ТекущийОбъект.ТипДанных = Перечисления.ТипыДанныхКэшаПрограммныхИнтерфейсов.ВерсииИнтерфейса Тогда
		
		Данные = ОбщегоНазначения.ЗначениеИзСтрокиXML(Тело);
		ТекущийОбъект.Данные = Новый ХранилищеЗначения(Данные);
		
	ИначеЕсли ТекущийОбъект.ТипДанных = Перечисления.ТипыДанныхКэшаПрограммныхИнтерфейсов.ОписаниеWebСервиса Тогда
		
		ВременныйФайл = ПолучитьИмяВременногоФайла("xml");
		
		ТекстовыйДокумент = Новый ТекстовыйДокумент();
		ТекстовыйДокумент.УстановитьТекст(Тело);
		ТекстовыйДокумент.Записать(ВременныйФайл);
		
		ДвоичныеДанные = Новый ДвоичныеДанные(ВременныйФайл);
		ТекущийОбъект.Данные = Новый ХранилищеЗначения(ДвоичныеДанные);
		
		УдалитьФайлы(ВременныйФайл);
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти