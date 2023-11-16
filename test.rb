require "google_drive"

# Creates a session. This will prompt the credential via command line for the
# first time and save it to config.json file for later usages.
# See this document to learn how to create config.json:
# https://github.com/gimite/google-drive-ruby/blob/master/doc/authorization.md
session = GoogleDrive::Session.from_config("config.json")

ws = session.spreadsheet_by_key("1Hr6fwRYBGk84fQuSVnI3vwiiFGFxB6KqmgUOLvz1kJo").worksheets[0]

def add_method(c, m, &b)
    c.class_eval {
      define_method(m, &b)
    }
end

GoogleDrive::Worksheet.class_eval do

    include Enumerable
    def each
        red = []
        self.rows.each do |row|
            row.each do |cell|
                red << cell        
            end
        end
        red
    end

    alias_method :original_uglaste, :[]
    def [](*args)
        if args.length == 1
            ime = args[0]
            kolona = []
            headers = self.rows[0]
            if headers.include?(ime)
                index = headers.index(ime)
                self.rows.each do |row|
                    kolona << row[index]
                end
                kolona
            else
                "greska"
            end
        else
            self.original_uglaste(*args)
        end
    end

    def method_missing(ime)
        ime = ime[0..-1]
        headers = self.rows[0]
        if headers.include?(ime)
            self[ime]
        else
            "greska"
        end
    end
end

add_method(GoogleDrive::Worksheet, :vrednosti) do
    vrednosti = []
    self.rows.each do |row|
        vrednosti << row
    end
    vrednosti
end

add_method(GoogleDrive::Worksheet, :row) do |index|
    self.rows[index]
end

Array.class_eval do
    def sum
        sum = 0
        self.each do |element|
            sum += element.to_i if element.match(/\A[0-9]+\Z/)
        end
        sum
    end
    def avg
        avg = 0
        br = 0
        self.each do |element|
            if element.match(/\A[0-9]+\Z/)
                avg += element.to_i
                br += 1
            end
        end
        avg/br
    end
end

p ws.vrednosti
p ws.row(4)
p ws["DrugaKolona"]
p ws["DrugaKolona"][2]
p ws.TrecaKolona.sum
p ws.TrecaKolona.avg
p ws.TrecaKolona