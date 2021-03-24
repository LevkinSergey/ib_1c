﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныйПрограммныйИнтерфейс

// Заполняет регистр обновленных данных для передачи в подчиненные узлы РИБ.
//
// Параметры:
//  Очередь - Число - очередь обработки, в которой выполняется текущий обработчик.
//  Данные  - Ссылка, Массив, НаборДанных - данные, по которым нужно зарегистрировать изменения.
//            Регистрация по независимому регистру сведений не поддерживается.
//  ДополнительныеПараметры - см. ОбновлениеИнформационнойБазы.ДополнительныеПараметрыОтметкиОбработки.
//
Процедура ОтметитьВыполнениеОбработки(Очередь, Данные, ДополнительныеПараметры) Экспорт
	
	Если (ПараметрыСеанса.ПараметрыОбработчикаОбновления.ЗапускатьТолькоВГлавномУзле 
			И Не СтандартныеПодсистемыПовтИсп.ИспользуетсяРИБ())
			Или (Не ПараметрыСеанса.ПараметрыОбработчикаОбновления.ЗапускатьТолькоВГлавномУзле
				И Не СтандартныеПодсистемыПовтИсп.ИспользуетсяРИБ("СФильтром"))
			Или ПараметрыСеанса.ПараметрыОбработчикаОбновления.ЗапускатьИВПодчиненномУзлеРИБСФильтрами Тогда
		Возврат;
	КонецЕсли;
	
	ТипДанных = ТипЗнч(Данные);
	
	Если ТипДанных = Тип("Массив")
		И Данные.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Если ПараметрыСеанса.ПараметрыОбработчикаОбновления.ЗапускатьТолькоВГлавномУзле Тогда
		УзлыРИБ = СтандартныеПодсистемыПовтИсп.УзлыРИБ();
	Иначе
		УзлыРИБ = СтандартныеПодсистемыПовтИсп.УзлыРИБ("СФильтром");
	КонецЕсли;
	
	Если УзлыРИБ.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Если ДополнительныеПараметры.ЭтоДвижения
		Или ДополнительныеПараметры.ЭтоНезависимыйРегистрСведений Тогда
		ИдентификаторОбъектаМетаданных = ОбщегоНазначения.ИдентификаторОбъектаМетаданных(ДополнительныеПараметры.ПолноеИмяРегистра);
	Иначе
		
		Если ТипДанных = Тип("Массив") Тогда
			ИдентификаторОбъектаМетаданных = Неопределено;
		Иначе
			ИдентификаторОбъектаМетаданных = ОбщегоНазначения.ИдентификаторОбъектаМетаданных(ТипДанных);
		КонецЕсли;
		
	КонецЕсли;
	
	НаборДанных = СоздатьНаборЗаписей();
	
	Если ЗначениеЗаполнено(ИдентификаторОбъектаМетаданных) Тогда
		НаборДанных.Отбор.ОбъектМетаданных.Установить(ИдентификаторОбъектаМетаданных);
	КонецЕсли;
	
	НаборДанных.Отбор.Очередь.Установить(Очередь);
	
	Если ДополнительныеПараметры.ЭтоДвижения Тогда
		ДобавитьДанныеВНабор(УзлыРИБ, НаборДанных, Данные);
	ИначеЕсли ДополнительныеПараметры.ЭтоНезависимыйРегистрСведений Тогда
		
		Для Каждого ЭлементДанных Из Данные Цикл
			
			СтруктураЗначенийИзмерений = Новый Структура;
			Идентификатор              = Новый УникальныйИдентификатор;
			
			НаборДанных.Отбор.КлючУникальности.Установить(Идентификатор);
			
			Для Каждого ЭлементОтбора Из Данные.Колонки Цикл
				СтруктураЗначенийИзмерений.Вставить(ЭлементОтбора.Имя, ЭлементДанных[ЭлементОтбора.Имя]);
			КонецЦикла;
			
			Для Каждого УзелРИБ Из УзлыРИБ Цикл
				
				НоваяСтрока = НаборДанных.Добавить();
				
				НоваяСтрока.УзелПланаОбмена                     = УзелРИБ.Значение;
				НоваяСтрока.ОбъектМетаданных                    = ИдентификаторОбъектаМетаданных;
				НоваяСтрока.КлючУникальности                    = Идентификатор;
				НоваяСтрока.Очередь                             = Очередь;
				НоваяСтрока.ЗначенияОтборовНезависимогоРегистра = Новый ХранилищеЗначения(СтруктураЗначенийИзмерений, Новый СжатиеДанных(9));
				
			КонецЦикла;
			
			ЗаписатьНаборИсключивСтандартнуюРегистрациюИзменений(НаборДанных, УзлыРИБ);
			
			НаборДанных = СоздатьНаборЗаписей();
			Если ЗначениеЗаполнено(ИдентификаторОбъектаМетаданных) Тогда
				НаборДанных.Отбор.ОбъектМетаданных.Установить(ИдентификаторОбъектаМетаданных);
			КонецЕсли;
			НаборДанных.Отбор.Очередь.Установить(Очередь);
			
		КонецЦикла;
		
	Иначе
		Если ТипЗнч(Данные) <> Тип("Массив") Тогда
			
			ОбъектМетаданных = Метаданные.НайтиПоТипу(ТипДанных);
			Если ОбщегоНазначения.ЭтоКонстанта(ОбъектМетаданных) Тогда
				Возврат;
			КонецЕсли;
			
			Если ОбщегоНазначения.ЭтоРегистрСведений(ОбъектМетаданных)
				И ОбъектМетаданных.РежимЗаписи = Метаданные.СвойстваОбъектов.РежимЗаписиРегистра.Независимый Тогда
				
				СтруктураЗначенийИзмерений = Новый Структура;
				Идентификатор                       = Новый УникальныйИдентификатор;
				
				НаборДанных.Отбор.КлючУникальности.Установить(Идентификатор);
				
				Для Каждого ЭлементОтбора Из Данные.Отбор Цикл
					СтруктураЗначенийИзмерений.Вставить(ЭлементОтбора.Имя, ЭлементОтбора.Значение);
				КонецЦикла;
				
				Для Каждого УзелРИБ Из УзлыРИБ Цикл
					
					НоваяСтрока = НаборДанных.Добавить();
					
					НоваяСтрока.УзелПланаОбмена                     = УзелРИБ.Значение;
					НоваяСтрока.ОбъектМетаданных                    = ИдентификаторОбъектаМетаданных;
					НоваяСтрока.КлючУникальности                    = Идентификатор;
					НоваяСтрока.Очередь                             = Очередь;
					НоваяСтрока.ЗначенияОтборовНезависимогоРегистра = Новый ХранилищеЗначения(СтруктураЗначенийИзмерений, Новый СжатиеДанных(9));
					
				КонецЦикла;
				
				ЗаписатьНаборИсключивСтандартнуюРегистрациюИзменений(НаборДанных, УзлыРИБ);
				Возврат;
				
			КонецЕсли;
			
			ДобавитьДанныеВНабор(УзлыРИБ, НаборДанных, Данные, ОбъектМетаданных);
			
		Иначе
			
			ДобавитьДанныеВНабор(УзлыРИБ, НаборДанных, Данные, , Очередь);
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ДобавитьДанныеВНабор(УзлыРИБ, НаборДанных, Данные, ОбъектМетаданных = Неопределено, Очередь = Неопределено)
	
	Если ТипЗнч(Данные) = Тип("Массив") Тогда
		
		Для Каждого ЭлементДанных Из Данные Цикл
			
			НаборДанных = СоздатьНаборЗаписей();
			НаборДанных.Отбор.Данные.Установить(ЭлементДанных);
			НаборДанных.Отбор.Очередь.Установить(Очередь);
			НаборДанных.Отбор.ОбъектМетаданных.Установить(ОбщегоНазначения.ИдентификаторОбъектаМетаданных(ТипЗнч(ЭлементДанных)));
			
			Для Каждого УзелРИБ Из УзлыРИБ Цикл
				НоваяСтрока = НаборДанных.Добавить();
				
				НоваяСтрока.УзелПланаОбмена  = УзелРИБ.Значение;
				НоваяСтрока.ОбъектМетаданных = НаборДанных.Отбор.ОбъектМетаданных.Значение;
				НоваяСтрока.Данные           = ЭлементДанных;
				НоваяСтрока.Очередь          = НаборДанных.Отбор.Очередь.Значение;
				
			КонецЦикла;
			
			ЗаписатьНаборИсключивСтандартнуюРегистрациюИзменений(НаборДанных, УзлыРИБ);
			
		КонецЦикла;
		
	Иначе
		
		Значение = Неопределено;
		
		Если ОбъектМетаданных = Неопределено Тогда
			ОбъектМетаданных = Метаданные.НайтиПоТипу(ТипЗнч(Данные));
		КонецЕсли;
		
		Если ОбщегоНазначения.ЭтоСсылка(ТипЗнч(Данные)) Тогда
			Значение = Данные;
		ИначеЕсли ОбщегоНазначения.ЭтоОбъектСсылочногоТипа(ОбъектМетаданных) Тогда
			Значение = Данные.Ссылка;
		Иначе
			Значение = Данные.Отбор.Регистратор.Значение;
		КонецЕсли;
		
		НаборДанных.Отбор.Данные.Установить(Значение);
		
		Если Не НаборДанных.Отбор.ОбъектМетаданных.Использование
			Или Не ЗначениеЗаполнено(НаборДанных.Отбор.ОбъектМетаданных.Значение) Тогда
			НаборДанных.Отбор.ОбъектМетаданных.Установить(ОбщегоНазначения.ИдентификаторОбъектаМетаданных(ТипЗнч(Значение)));
		КонецЕсли;
		
		Для Каждого УзелРИБ Из УзлыРИБ Цикл
			
			НоваяСтрока = НаборДанных.Добавить();
			
			НоваяСтрока.УзелПланаОбмена  = УзелРИБ.Значение;
			НоваяСтрока.ОбъектМетаданных = НаборДанных.Отбор.ОбъектМетаданных.Значение;
			НоваяСтрока.Данные           = Значение;
			НоваяСтрока.Очередь          = НаборДанных.Отбор.Очередь.Значение;
			
		КонецЦикла;
		
		ЗаписатьНаборИсключивСтандартнуюРегистрациюИзменений(НаборДанных, УзлыРИБ);
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ЗаписатьНаборИсключивСтандартнуюРегистрациюИзменений(НаборДанных, УзлыРИБ)
	
	// Записываем набор, заменяя стандартную логику регистрации собственной.
	РегистрируемыйНабор = СоздатьНаборЗаписей();
	Для Каждого ЭлементОтбора Из НаборДанных.Отбор Цикл
		РегистрируемыйНабор.Отбор[ЭлементОтбора.Имя].Установить(ЭлементОтбора.Значение);
	КонецЦикла;
	
	Для Каждого ЭлементСписка Из УзлыРИБ Цикл
		
		УзелРИБ = ЭлементСписка.Значение;
		РегистрируемыйНабор.Отбор.УзелПланаОбмена.Установить(УзелРИБ);
		ПланыОбмена.ЗарегистрироватьИзменения(УзелРИБ, РегистрируемыйНабор);
		
	КонецЦикла;
	
	НаборДанных.ДополнительныеСвойства.Вставить("ОтключитьМеханизмРегистрацииОбъектов");
	НаборДанных.Записать();
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли