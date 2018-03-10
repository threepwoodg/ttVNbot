module HashParse
  def hash_parse (hash)
    hash.each { |key,value| if key=="records"
                              #@@tt_counters = value
                              File.open("counters", 'a+') {|file| file.write value}
                            elsif
                            key=="rows"
                              value.each {|array| array.each {|keytt,valuett| if keytt=="ticketNo"
                                                                                File.open("temp", 'a+') {|file| file.write "Номер: <a href=\"https://172.21.231.235/ttms/ticket?id=#{valuett}\">#{valuett}</a> <a href=\"https://172.21.231.235/ttms/ttedit?id=#{valuett}&block_id=1,2,3\">Решить</a> \n"}
                                                                              elsif keytt=="depStatus"
                                                                                if valuett!="Отдельный"
                                                                                  File.open("temp", 'a+') {|file| file.write "Подчинение: #{valuett}\n"}
                                                                                  @dep_status = valuett
                                                                                end
                                                                              elsif keytt=="ticketType"
                                                                                File.open("temp", 'a+') {|file| file.write "Тип: #{valuett}\n"}
                                                                              elsif keytt=="depCount"
                                                                                  if @dep_status=="Главный"
                                                                                    File.open("temp", 'a+') {|file| file.write "В подчинении инцидентов: #{valuett}\n"}
                                                                                  elsif @dep_status=="Подчиненный"
                                                                                    File.open("temp", 'a+') {|file| file.write "Главный: <a href=\"https://172.21.231.235/ttms/ticket?id=#{valuett}\">#{valuett}</a>\n"}
                                                                                  end
                                                                              elsif keytt=="servStat"
                                                                                File.open("temp", 'a') {|file| file.write "Статус: #{valuett}\n"}
                                                                              elsif keytt=="timeToSolve"
                                                                                valuett.each {|key,value| if key=="value"
                                                                                                            File.open("temp", 'a') {|file| file.write "Целевой срок решения: #{value}\n"}
                                                                                                          end
                                                                                }
                                                                              elsif keytt=="pr"
                                                                                File.open("temp", 'a') {|file| file.write "Приоритет: #{valuett}\n\n"}
                                                                              end
                                                              }
                                          }
                            end
    }
  end

  def get_list (hash)
    @tt = Array.new
    hash.each do |key,array|
      if key=="records" && array==0
        return 0
      elsif key=="rows"
        array.each do |tt_hash|
          tt_hash.each do |tt_key,tt_value|
            if tt_key=="ticketNo"
              #Array[0] Номер инцидента
              @tt_num = Array.new
              @tt_num << tt_value.to_s
            elsif tt_key=="depStatus"
              #Array Подчинение инцидента (отдельный/главный/подчиненный)
              #@tt_num << tt_value
              if tt_value!="Отдельный"
                @dep_status = tt_value
              end
            elsif tt_key=="ticketType"
              #Array[1] Тип инцидента (инфраструктурынй/клиентский)
              @tt_num << tt_value
            elsif tt_key=="depCount"
              #Array[2] В подчинении (в подчинении инцидетов/в подчинении у)
              #@tt_num << tt_value
              if @dep_status=="Главный"
                @tt_num << "В подчинении инцидентов: #{tt_value}\n"
              elsif @dep_status=="Подчиненный"
                @tt_num << "В подчинении у : #{tt_value}"
              else
                @tt_num << "Отдельный"
              end
            elsif tt_key=="servStat"
              #Array[3] Статус услуги (недоступна/доступна)
              @tt_num << tt_value
            elsif tt_key=="descr"
              #Array[4] Описание
              @tt_num << tt_value
            elsif tt_key=="timeToSolve"
              #Array[5] Целевой срок решения
              tt_value.each do |key,value|
                if key=="value"
                  @tt_num << value
                end
              end
            elsif tt_key=="pr"
              #Array[6] Приоритет
              @tt_num << tt_value.to_s
              if File.exist?("lib/tt/#{@tt_num[0]}")
                #Array[7] Комментарий к инциденту
                json_file = File.open("lib/tt/#{@tt_num[0]}", 'r'){ |file| file.read }
                data_hash = JSON.parse(json_file)
                data_hash.each do |k,v|
                  if k=="user"
                    @user = v
                  elsif k=="comment"
                    @comment = v
                  end
                end
                @tt_num << "#{@user}: #{@comment}"
                @user = nil
                @comment = nil
              else
                @tt_num << "Нет комментария к инциденту"
              end
              @tt << @tt_num
              @tt_num = nil
            end
          end
        end
      end
    end
    return @tt
  end

  def tt_by_number (hash,number)
    hash.each do |key,array|
      if key=="rows"
        array.each do |tt_hash|
            if tt_hash.values.include?(number.to_i)
              @tt_bn = Array.new
              tt_hash.each do |tt_key,tt_value|
                if tt_key=="ticketNo"
                  #Array[0] Номер инцидента
                  @tt_bn << tt_value.to_s
                elsif tt_key=="depStatus"
                  #Array[1] Подчинение инцидента (отдельный/главный/подчиненный)
                  #@tt_bn << tt_value
                  if tt_value!="Отдельный"
                    @dep_status = tt_value
                  end
                elsif tt_key=="ticketType"
                  #Array[1] Тип инцидента (инфраструктурынй/клиентский)
                  @tt_bn << tt_value
                elsif tt_key=="depCount"
                  #Array[2] В подчинении (в подчинении инцидетов/в подчинении у)
                  #@tt_bn << tt_value
                  if @dep_status=="Главный"
                    @tt_bn << "В подчинении инцидентов: #{tt_value}\n"
                  elsif @dep_status=="Подчиненный"
                    @tt_bn << "В подчинении у : #{tt_value}"
                  else
                    @tt_bn << @dep_status
                  end
                elsif tt_key=="servStat"
                  #Array[3] Статус услуги (недоступна/доступна)
                  @tt_bn << tt_value
                elsif tt_key=="descr"
                  #Array[4] Описание
                  @tt_bn << tt_value
                elsif tt_key=="timeToSolve"
                  #Array[5] Целевой срок решения
                  tt_value.each do |key,value|
                    if key=="value"
                      @tt_bn << value
                    end
                  end
                elsif tt_key=="pr"
                  #Array[6] Приоритет
                  @tt_bn << tt_value.to_s
                  if File.exist?("lib/tt/#{number}")
                    #Array[7] Комментарий к инциденту
                    json_file = File.open("lib/tt/#{number}", 'r'){ |file| file.read }
                    data_hash = JSON.parse(json_file)
                    data_hash.each do |k,v|
                      if k=="user"
                        @user = v
                      elsif k=="comment"
                        @comment = v
                      end
                    end
                    @tt_bn << "#{@user}: #{@comment}"
                  else
                    @tt_bn << "Нет комментария к инциденту"
                  end
                  return @tt_bn
                end
              end
            end
        end
      end
    end
    return 0
  end

end