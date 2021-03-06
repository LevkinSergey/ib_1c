
Процедура ДобавитьОтсутствующиеНастройкиПользователяВРегистр(владелецНастроек) экспорт
	
	если не ОбщегоНазначенияИнформбюроСервер.ЗначениеИмеетТип(владелецНастроек, "СправочникСсылка.Пользователи") тогда
		возврат;
	конецЕсли;	
	
	запрос = новый запрос;
	запрос.Текст = "ВЫБРАТЬ
	               |	ПользовательскиеЗначенияПоУмолчанию.Настройка КАК Настройка,
	               |	ПользовательскиеЗначенияПоУмолчанию.Значение КАК Значение
	               |ПОМЕСТИТЬ втНастройкиПользователя
	               |ИЗ
	               |	РегистрСведений.ПользовательскиеЗначенияПоУмолчанию КАК ПользовательскиеЗначенияПоУмолчанию
	               |ГДЕ
	               |	ПользовательскиеЗначенияПоУмолчанию.Пользователь = &Пользователь
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	НастройкиПользователей.Ссылка КАК Настройка,
	               |	НастройкиПользователей.ТипЗначения КАК ТипЗначения,
	               |	ЕСТЬNULL(втНастройкиПользователя.Значение, НЕОПРЕДЕЛЕНО) КАК Значение
	               |ИЗ
	               |	ПланВидовХарактеристик.НастройкиПользователей КАК НастройкиПользователей
	               |		ЛЕВОЕ СОЕДИНЕНИЕ втНастройкиПользователя КАК втНастройкиПользователя
	               |		ПО НастройкиПользователей.Ссылка = втНастройкиПользователя.Настройка
	               |ГДЕ
	               |	втНастройкиПользователя.Значение ЕСТЬ NULL";
	
	запрос.УстановитьПараметр("Пользователь", владелецНастроек);
	выбРезультатЗапроса = запрос.Выполнить().Выбрать();
	
	пока выбРезультатЗапроса.Следующий() цикл
			
		записьРегистраНастроек = РегистрыСведений.ПользовательскиеЗначенияПоУмолчанию.СоздатьМенеджерЗаписи();
	
		записьРегистраНастроек.Настройка = выбРезультатЗапроса.Настройка;
		записьРегистраНастроек.Пользователь = владелецНастроек;
		
		если выбРезультатЗапроса.ТипЗначения.Типы().Количество() = 1 тогда
			записьРегистраНастроек.Значение = ОбщегоНазначенияИнформбюроСервер.ПолучитьПустоеЗначениеПоТипу(выбРезультатЗапроса.ТипЗначения);
		иначе	
			записьРегистраНастроек.Значение = неопределено;
		конецЕсли;
		
		записьРегистраНастроек.Записать(ложь);
	
	КонецЦикла;	
	
КонецПроцедуры	