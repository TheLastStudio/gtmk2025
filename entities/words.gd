extends Node

const DIACRITIC_MAP := {
	"á": "a", "à": "a", "ä": "a", "â": "a", "ā": "a", "ã": "a", "å": "a", "ă": "a", "ą": "a",
	"ç": "c", "ć": "c", "č": "c", "ĉ": "c", "ċ": "c",
	"ď": "d", "đ": "d",
	"é": "e", "è": "e", "ë": "e", "ê": "e", "ē": "e", "ę": "e", "ě": "e", "ĕ": "e", "ė": "e",
	"ƒ": "f",
	"ĝ": "g", "ğ": "g", "ġ": "g", "ģ": "g",
	"ĥ": "h", "ħ": "h",
	"í": "i", "ì": "i", "ï": "i", "î": "i", "ī": "i", "į": "i", "ı": "i",
	"ĵ": "j",
	"ķ": "k",
	"ĺ": "l", "ľ": "l", "ļ": "l", "ł": "l",
	"ñ": "n", "ń": "n", "ň": "n", "ņ": "n", "ŋ": "n",
	"ó": "o", "ò": "o", "ö": "o", "ô": "o", "õ": "o", "ő": "o", "ø": "o", "ō": "o",
	"ŕ": "r", "ř": "r", "ŗ": "r",
	"ś": "s", "š": "s", "ş": "s", "ŝ": "s", "ș": "s",
	"ť": "t", "ţ": "t", "ŧ": "t", "ț": "t",
	"ú": "u", "ù": "u", "ü": "u", "û": "u", "ū": "u", "ů": "u", "ű": "u", "ų": "u",
	"ŵ": "w",
	"ý": "y", "ÿ": "y", "ŷ": "y",
	"ž": "z", "ż": "z", "ź": "z",
	"ß": "b",
	"þ": "p", "ð": "d",
	"æ": "ae", "œ": "oe",
}

const CHAR_SUBSTITUTIONS := {
	"a": ["a", "@", "4", "а"],
	"b": ["b", "8", "ß"],
	"c": ["c", "(", "<", "с"],
	"d": ["d", "д"],
	"e": ["e", "3", "€", "є"],
	"g": ["g", "9", "6"],
	"i": ["i", "1", "!", "|", "і", "¡", "l"],
	"l": ["l", "1", "|", "!", "¡"],
	"n": ["n", "п"],
	"o": ["o", "0", "о", "°"],
	"r": ["r", "®"],
	"s": ["s", "5", "$", "§"],
	"t": ["t", "7", "+"],
	"u": ["u", "v", "ü"],
	"z": ["z", "2"]
}

const REGEX_SPECIAL_CHARS := ['\\', '.', '^', '$', '*', '+', '?', '{', '}', '[', ']', '|', '(', ')']

func regex_escape(_char: String) -> String:
	if _char in REGEX_SPECIAL_CHARS:
		return "\\" + _char
	return _char

func remove_diacritics(text: String) -> String:
	var result := ""
	for c in text.to_lower():
		if DIACRITIC_MAP.has(c):
			result += DIACRITIC_MAP[c]
		else:
			result += c
	return result

func build_pattern(word: String) -> String:
	var pattern := ""
	var normalized_word := remove_diacritics(word.to_lower())
	for c in normalized_word:
		var options = CHAR_SUBSTITUTIONS.get(c, [c])
		var escaped := []
		for opt in options:
			escaped.append(regex_escape(opt))
		pattern += "[" + "".join(escaped) + r"]\W*"
	return pattern

func contains_forbidden_words(text: String) -> bool:
	var normalized_text := remove_diacritics(text.to_lower())
	for word in forbidden_words:
		var pattern := build_pattern(word)
		var regex := RegEx.new()
		regex.compile(pattern)
		if regex.search(normalized_text):
			return true
	return false


var forbidden_words = ['Asesinato', 'Bollera', 'Caca', 'Chupada', 'Chupapollas', 'Concha de tu madre', 'Culo', 'Drogas', 'Esperma', 'Fiesta de salchichas', 'Follador', 'Follar', 'Gilipichis', 'Gilipollas', 'Hacer una paja', 'Haciendo el amor', 'Hija de puta', 'Hijaputa', 'Hijo de puta', 'Hijoputa', 'Idiota', 'Jilipollas', 'Kapullo', 'Lameculos', 'MILF', 'Maciza', 'Macizorra', 'Mamada', 'Marica', 'Mariconazo', 'Mierda', 'Nazi', 'Orina', 'Pedo', 'Pendejo', 'Pervertido', 'Pinche', 'Pis', 'Prostituta', 'Puta', 'Racista', 'Ramera', 'Semen', 'Sexo', 'Sexo oral', 'Soplagaitas', 'Soplapollas', 'Tetas grandes', 'Travesti', 'Trio', 'Verga', 'Vulva', 'acrotomophilia', 'alabama hot pocket', 'alaskan pipeline', 'anal', 'analritter', 'anilingus', 'anus', 'apeshit', 'arsch', 'arschficker', 'arschlecker', 'arschloch', 'arsehole', 'asno', 'ass', 'asshole', 'assmunch', 'auto erotic', 'autoerotic', 'babeland', 'baby batter', 'baby juice', 'ball gag', 'ball gravy', 'ball kicking', 'ball licking', 'ball sack', 'ball sucking', 'bangbros', 'bangbus', 'bareback', 'barely legal', 'barenaked', 'bastard', 'bastardo', 'bastinado', 'bbw', 'bdsm', 'beaner', 'beaners', 'beastiality', 'beaver cleaver', 'beaver lips', 'bestiality', 'big black', 'big breasts', 'big knockers', 'big tits', 'bimbo', 'bimbos', 'birdlock', 'bitch', 'bitches', 'black cock', 'blonde action', 'blonde on blonde action', 'blow job', 'blow your load', 'blowjob', 'blue waffle', 'blumpkin', 'bollocks', 'bondage', 'boner', 'bonze', 'boob', 'boobs', 'booty call', 'bratze', 'brown showers', 'brunette action', 'bukkake', 'bulldyke', 'bullet vibe', 'bullshit', 'bumsen', 'bung hole', 'bunghole', 'burdel', 'burdelmama', 'busty', 'butt', 'buttcheeks', 'butthole', 'bychara', 'byk', 'camel toe', 'camgirl', 'camslut', 'camwhore', 'carpet muncher', 'carpetmuncher', 'chernozhopyi', 'chocolate rosebuds', 'chuj', 'chujnia', 'cialis', 'ciota', 'cipa', 'circlejerk', 'cleveland steamer', 'clit', 'clitoris', 'clover clamps', 'clusterfuck', 'cock', 'cocks', 'concha', 'coon', 'coons', 'coprolagnia', 'coprophilia', 'cornhole', 'creampie', 'cum', 'cumming', 'cumshot', 'cumshots', 'cunnilingus', 'cunt', 'cyc', 'darkie', 'date rape', 'daterape', 'debil', 'deep throat', 'deepthroat', 'dendrophilia', 'dick', 'dildo', 'dingleberries', 'dingleberry', 'dirty pillows', 'dirty sanchez', 'dog style', 'doggie style', 'doggiestyle', 'doggy style', 'doggystyle', 'dolcett', 'domination', 'dominatrix', 'dommes', 'donkey punch', 'double dong', 'double penetration', 'dp action', 'dry hump', 'dupa', 'dupek', 'duperele', 'dvda', 'dziwka', 'eat my ass', 'ebalnik', 'ebalo', 'ecchi', 'ejaculation', 'erotic', 'erotism', 'escort', 'eunuch', 'fag', 'faggot', 'fecal', 'felch', 'fellatio', 'feltch', 'female squirting', 'femdom', 'fick', 'ficken', 'figging', 'fingerbang', 'fingering', 'fisting', 'fiut', 'flittchen', 'foot fetish', 'footjob', 'fotze', 'fratze', 'frotting', 'fuck', 'fuck buttons', 'fuckin', 'fucking', 'fucktards', 'fudge packer', 'fudgepacker', 'futanari', 'gang bang', 'gangbang', 'gay sex', 'genitals', 'giant cock', 'girl on', 'girl on top', 'girls gone wild', 'goatcx', 'goatse', 'god damn', 'gokkun', 'gol', 'golden shower', 'goo girl', 'goodpoop', 'goregasm', 'grope', 'group sex', 'guro', 'hackfresse', 'hand job', 'handjob', 'hard core', 'hardcore', 'hentai', 'homoerotic', 'honkey', 'hooker', 'horny', 'hot carl', 'hot chick', 'how to kill', 'how to murder', 'huge fat', 'huj', 'humping', 'hure', 'hurensohn', 'incest', 'infierno', 'intercourse', 'ische', 'jack off', 'jail bait', 'jailbait', 'jajco', 'jajko', 'jebany', 'jelly donut', 'jerk off', 'jigaboo', 'jiggaboo', 'jiggerboo', 'jizz', 'juggs', 'kackbratze', 'kacke', 'kacken', 'kackwurst', 'kampflesbe', 'kanake', 'kike', 'kimme', 'kinbaku', 'kinkster', 'kinky', 'knobbing', 'kurwa', 'kurwy', 'kutafon', 'kutas', 'leather restraint', 'leather straight jacket', 'lemon party', 'livesex', 'lolita', 'lovemaking', 'make me come', 'maldito', 'male squirting', 'martillo', 'masturbate', 'masturbating', 'masturbation', 'menage a trois', 'milf', 'missionary position', 'mong', 'morgenlatte', 'motherfucker', 'mound of venus', 'mr hands', 'mudack', 'muff diver', 'muffdiving', 'mufti', 'muschi', 'nackt', 'nambla', 'nawashi', 'neger', 'negro', 'neonazi', 'nig nog', 'nigga', 'nigger', 'nimphomania', 'nippel', 'nipple', 'nipples', 'nsfw', 'nsfw images', 'nude', 'nudity', 'nutte', 'nutten', 'nympho', 'nymphomania', 'octopussy', 'omorashi', 'onanieren', 'one cup two girls', 'one guy one jar', 'opizdenet', 'orgasm', 'orgasmus', 'orgy', 'otmudohat', 'otpizdit', 'otsosi', 'padlo', 'paedophile', 'paki', 'panties', 'panty', 'pedik', 'pedobear', 'pedophile', 'pegging', 'penis', 'perdet', 'petuh', 'phone sex', 'pidar gnoinyj', 'piece of shit', 'pierdolec', 'pikey', 'pimmel', 'pimpern', 'pinkeln', 'piss pig', 'pissen', 'pisser', 'pissing', 'pisspig', 'pizda', 'pizdato', 'pizdatyi', 'pizdetc', 'playboy', 'pleasure chest', 'po khuy', 'poeben', 'pojeb', 'pojebany', 'pole smoker', 'poluchit pizdy', 'ponyplay', 'poof', 'poon', 'poontang', 'poop chute', 'poopchute', 'popel', 'popierdolony', 'poppen', 'porn', 'porno', 'pornography', 'pososi moyu konfetku', 'prince albert piercing', 'prissat', 'proebat', 'propezdoloch', 'prosrat', 'pthc', 'pubes', 'punany', 'pussy', 'queaf', 'queef', 'quim', 'raghead', 'raging boner', 'rape', 'raping', 'rapist', 'raspeezdeyi', 'raspizdatyi', 'rectum', 'reudig', 'reverse cowgirl', 'rimjob', 'rimming', 'robic loda', 'rosette', 'rosy palm', 'rusty trombone', 'sadism', 'santorum', 'scat', 'schabracke', 'scheisser', 'schiesser', 'schlampe', 'schlong', 'schnackeln', 'schwanzlutscher', 'schwuchtel', 'scissoring', 'semen', 'sex', 'sexcam', 'sexo', 'sexual', 'sexuality', 'sexually', 'sexy', 'shalava', 'shaved beaver', 'shaved pussy', 'shemale', 'shibari', 'shit', 'shitblimp', 'shitty', 'shota', 'shrimping', 'skeet', 'skurwysyn', 'slanteye', 'slut', 'smut', 'snatch', 'snowballing', 'sodomize', 'sodomy', 'spastic', 'spic', 'splooge', 'splooge moose', 'spooge', 'spread legs', 'spunk', 'sraczka', 'strap on', 'strapon', 'strappado', 'strip club', 'styervo', 'style doggy', 'suck', 'sucks', 'suicide girls', 'suka', 'sukin syn', 'sultry women', 'svodit posrat', 'svoloch', 'swastika', 'swinger', 'syf', 'tainted love', 'taste my', 'tea bagging', 'threesome', 'throating', 'thumbzilla', 'tied up', 'tight white', 'tit', 'tits', 'tittchen', 'titten', 'titties', 'titty', 'tongue in a', 'topless', 'tosser', 'towelhead', 'tranny', 'tribadism', 'trimandoblydskiy pizdoproyob', 'tub girl', 'tubgirl', 'tushy', 'twat', 'twink', 'twinkie', 'two girls one cup', 'uboy', 'undressing', 'upskirt', 'urethra play', 'urophilia', 'pizdu', 'vafli lovit', 'vagina', 'venus mound', 'vete a la mierda', 'viagra', 'vibrator', 'violet wand', 'vollpfosten', 'vorarephilia', 'voyeur', 'voyeurweb', 'voyuer', 'vulva', 'vyperdysh', 'vzdrochennyi', 'wank', 'wet dream', 'wetback', 'white power', 'whore', 'wichse', 'wichsen', 'wichser', 'worldsex', 'wrapping men', 'wrinkled starfish', 'xxx', 'yeb vas', 'yellow showers', 'yiffy', 'zaebis', 'zajebisty', 'zalupa', 'zalupat', 'zasranetc', 'zassat', 'zoophilia', 'бздёнок', 'блядки', 'блядовать', 'блядство', 'блядь', 'бугор', 'пизду', 'выёбываться', 'гандон', 'говно', 'говнюк', 'голый', 'пизды', 'дерьмо', 'дрочить', 'ебать', 'ебло', 'ебнуть', 'жопа', 'жополиз', 'измудохать', 'рочит', 'обоссать', 'малофья', 'манда', 'мандавошка', 'мент', 'муда', 'мудило', 'мудозвон', 'фиг', 'хуй', 'хую', 'хуя', 'наебать', 'наебениться', 'наебнуться', 'нахуячиться', 'ебет', 'невебенный', 'хуя', 'обнаженный', 'обоссаться', 'ебётся', 'опесдол', 'офигеть', 'охуеть', 'охуительно', 'сношение', 'секс', 'сиськи', 'спиздить', 'срать', 'ссать', 'траxать', 'ы', 'фига', 'хапать', 'хер', 'хер', 'хохол', 'хрен', 'хуеплет', 'хуило', 'хуиня', 'хуй', 'хуй пинать', 'хуйнуть', 'хуёво', 'хуёвый', 'ёб', 'ёбарь']
