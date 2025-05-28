class Startup < ActiveRecord::Base
  has_many :members
	belongs_to :user
	has_many :pivots
  has_many :entries
  acts_as_followable

    def set_initial_status
      self.publish_startup
    end
    
    STATUSES = [STATUS_PUBLISHED = 'PUBLISHED', STATUS_LEARNING = 'LEARNING', STATUS_PIVOTING = 'PIVOTING', STATUS_DELETED = 'DELETED']
    
    #filtro para obtener las startup cuando el status = published
    scope :published, -> { Startup.where("status = '#{Startup::STATUS_PUBLISHED}' OR status = '#{Startup::STATUS_PIVOTING}'") }
    
    scope :pivoting, -> { where(status: Startup::STATUS_PIVOTING) }

    validates :status, inclusion: {in: STATUSES}

    def publish_startup
        self.status = Startup::STATUS_PUBLISHED
    end
    
    def pivot_startup
        self.status = Startup::STATUS_PIVOTING
    end
    
    def delete_startup
        self.status = Startup::STATUS_DELETED
    end
    
    def end_pivot_startup
      self.status = Startup::STATUS_LEARNING
    end

    def has_video?
      !self.videopitch.blank?
    end
  
    def pivots_count
      self.pivots.count
    end
    
    def members_count
      self.members.count
    end

    def entries_count
      self.entries.count
    end  
    def country_name
      self.countries.key(self.country)
    end
    
    def countries
      {
      'AF' => 'Afghanistan', 'AX' => 'Aland Islands', 'AL' => 'Albania', 'DZ' => 'Algeria', 'AS' => 'American Samoa', 'AD' => 'Andorra', 'AO' => 'Angola',
      'AI' => 'Anguilla','AQ' => 'Antarctica', 'AG' => 'Antigua And Barbuda', 'AR' => 'Argentina', 'AM' => 'Armenia', 'AW' => 'Aruba', 'AU' => 'Australia',
      'AT' => 'Austria', 'AZ' => 'Azerbaijan', 'BS' => 'Bahamas', 'BH' => 'Bahrain', 'BD' => 'Bangladesh', 'BB' => 'Barbados','BY' => 'Belarus', 'BE' => 'Belgium',
      'BZ' => 'Belize', 'BJ' => 'Benin', 'BM' => 'Bermuda', 'BT' => 'Bhutan', 'BO' => 'Bolivia','BA' => 'Bosnia And Herzegovina','BW' => 'Botswana', 'BV' => 'Bouvet Island',
      'BR' => 'Brazil', 'IO' => 'British Indian Ocean Territory','BN' => 'Brunei Darussalam','BG' => 'Bulgaria','BF' => 'Burkina Faso','BI' => 'Burundi','KH' => 'Cambodia',
      'CM' => 'Cameroon','CA' => 'Canada','CV' => 'Cape Verde','KY' => 'Cayman Islands','CF' => 'Central African Republic','TD' => 'Chad','CL' => 'Chile','CN' => 'China',
      'CX' => 'Christmas Island',
      'CC' => 'Cocos (Keeling) Islands',
      'CO' => 'Colombia',
      'KM' => 'Comoros',
      'CG' => 'Congo',
      'CD' => 'Congo, Democratic Republic',
      'CK' => 'Cook Islands',
      'CR' => 'Costa Rica',
      'CI' => 'Cote D\'Ivoire',
      'HR' => 'Croatia',
      'CU' => 'Cuba',
      'CY' => 'Cyprus',
      'CZ' => 'Czech Republic',
      'DK' => 'Denmark',
      'DJ' => 'Djibouti',
      'DM' => 'Dominica',
      'DO' => 'Dominican Republic',
      'EC' => 'Ecuador',
      'EG' => 'Egypt',
      'SV' => 'El Salvador',
      'GQ' => 'Equatorial Guinea',
      'ER' => 'Eritrea',
      'EE' => 'Estonia',
      'ET' => 'Ethiopia',
      'FK' => 'Falkland Islands (Malvinas)',
      'FO' => 'Faroe Islands',
      'FJ' => 'Fiji',
      'FI' => 'Finland',
      'FR' => 'France',
      'GF' => 'French Guiana',
      'PF' => 'French Polynesia',
      'TF' => 'French Southern Territories',
      'GA' => 'Gabon',
      'GM' => 'Gambia',
      'GE' => 'Georgia',
      'DE' => 'Germany',
      'GH' => 'Ghana',
      'GI' => 'Gibraltar',
      'GR' => 'Greece',
      'GL' => 'Greenland',
      'GD' => 'Grenada',
      'GP' => 'Guadeloupe',
      'GU' => 'Guam',
      'GT' => 'Guatemala',
      'GG' => 'Guernsey',
      'GN' => 'Guinea',
      'GW' => 'Guinea-Bissau',
      'GY' => 'Guyana',
      'HT' => 'Haiti',
      'HM' => 'Heard Island & Mcdonald Islands',
      'VA' => 'Holy See (Vatican City State)',
      'HN' => 'Honduras',
      'HK' => 'Hong Kong',
      'HU' => 'Hungary',
      'IS' => 'Iceland',
      'IN' => 'India',
      'ID' => 'Indonesia',
      'IR' => 'Iran, Islamic Republic Of',
      'IQ' => 'Iraq',
      'IE' => 'Ireland',
      'IM' => 'Isle Of Man',
      'IL' => 'Israel',
      'IT' => 'Italy',
      'JM' => 'Jamaica',
      'JP' => 'Japan',
      'JE' => 'Jersey',
      'JO' => 'Jordan',
      'KZ' => 'Kazakhstan',
      'KE' => 'Kenya',
      'KI' => 'Kiribati',
      'KR' => 'Korea',
      'KW' => 'Kuwait',
      'KG' => 'Kyrgyzstan',
      'LA' => 'Lao People\'s Democratic Republic',
      'LV' => 'Latvia',
      'LB' => 'Lebanon',
      'LS' => 'Lesotho',
      'LR' => 'Liberia',
      'LY' => 'Libyan Arab Jamahiriya',
      'LI' => 'Liechtenstein',
      'LT' => 'Lithuania',
      'LU' => 'Luxembourg',
      'MO' => 'Macao',
      'MK' => 'Macedonia',
      'MG' => 'Madagascar',
      'MW' => 'Malawi',
      'MY' => 'Malaysia',
      'MV' => 'Maldives',
      'ML' => 'Mali',
      'MT' => 'Malta',
      'MH' => 'Marshall Islands',
      'MQ' => 'Martinique',
      'MR' => 'Mauritania',
      'MU' => 'Mauritius',
      'YT' => 'Mayotte',
      'MX' => 'Mexico',
      'FM' => 'Micronesia, Federated States Of',
      'MD' => 'Moldova',
      'MC' => 'Monaco',
      'MN' => 'Mongolia',
      'ME' => 'Montenegro',
      'MS' => 'Montserrat',
      'MA' => 'Morocco',
      'MZ' => 'Mozambique',
      'MM' => 'Myanmar',
      'NA' => 'Namibia',
      'NR' => 'Nauru',
      'NP' => 'Nepal',
      'NL' => 'Netherlands',
      'AN' => 'Netherlands Antilles',
      'NC' => 'New Caledonia',
      'NZ' => 'New Zealand',
      'NI' => 'Nicaragua',
      'NE' => 'Niger',
      'NG' => 'Nigeria',
      'NU' => 'Niue',
      'NF' => 'Norfolk Island',
      'MP' => 'Northern Mariana Islands',
      'NO' => 'Norway',
      'OM' => 'Oman',
      'PK' => 'Pakistan',
      'PW' => 'Palau',
      'PS' => 'Palestinian Territory, Occupied',
      'PA' => 'Panama',
      'PG' => 'Papua New Guinea',
      'PY' => 'Paraguay',
      'PE' => 'Peru',
      'PH' => 'Philippines',
      'PN' => 'Pitcairn',
      'PL' => 'Poland',
      'PT' => 'Portugal',
      'PR' => 'Puerto Rico',
      'QA' => 'Qatar',
      'RE' => 'Reunion',
      'RO' => 'Romania',
      'RU' => 'Russian Federation',
      'RW' => 'Rwanda',
      'BL' => 'Saint Barthelemy',
      'SH' => 'Saint Helena',
      'KN' => 'Saint Kitts And Nevis',
      'LC' => 'Saint Lucia',
      'MF' => 'Saint Martin',
      'PM' => 'Saint Pierre And Miquelon',
      'VC' => 'Saint Vincent And Grenadines',
      'WS' => 'Samoa',
      'SM' => 'San Marino',
      'ST' => 'Sao Tome And Principe',
      'SA' => 'Saudi Arabia',
      'SN' => 'Senegal',
      'RS' => 'Serbia',
      'SC' => 'Seychelles',
      'SL' => 'Sierra Leone',
      'SG' => 'Singapore',
      'SK' => 'Slovakia',
      'SI' => 'Slovenia',
      'SB' => 'Solomon Islands',
      'SO' => 'Somalia',
      'ZA' => 'South Africa',
      'GS' => 'South Georgia And Sandwich Isl.',
      'ES' => 'Spain',
      'LK' => 'Sri Lanka',
      'SD' => 'Sudan',
      'SR' => 'Suriname',
      'SJ' => 'Svalbard And Jan Mayen',
      'SZ' => 'Swaziland',
      'SE' => 'Sweden',
      'CH' => 'Switzerland',
      'SY' => 'Syrian Arab Republic',
      'TW' => 'Taiwan',
      'TJ' => 'Tajikistan',
      'TZ' => 'Tanzania',
      'TH' => 'Thailand',
      'TL' => 'Timor-Leste',
      'TG' => 'Togo',
      'TK' => 'Tokelau',
      'TO' => 'Tonga',
      'TT' => 'Trinidad And Tobago',
      'TN' => 'Tunisia',
      'TR' => 'Turkey',
      'TM' => 'Turkmenistan',
      'TC' => 'Turks And Caicos Islands',
      'TV' => 'Tuvalu',
      'UG' => 'Uganda',
      'UA' => 'Ukraine',
      'AE' => 'United Arab Emirates',
      'GB' => 'United Kingdom',
      'US' => 'United States',
      'UM' => 'United States Outlying Islands',
      'UY' => 'Uruguay',
      'UZ' => 'Uzbekistan',
      'VU' => 'Vanuatu',
      'VE' => 'Venezuela',
      'VN' => 'Viet Nam',
      'VG' => 'Virgin Islands, British',
      'VI' => 'Virgin Islands, U.S.',
      'WF' => 'Wallis And Futuna',
      'EH' => 'Western Sahara',
      'YE' => 'Yemen',
      'ZM' => 'Zambia',
      'ZW' => 'Zimbabwe',
    }.invert
  end
    
    
    def currentPivot  
      pivot = self.pivots.find(:last, :conditions => [ "status = ?", true ])
      if pivot.nil?
        false
      else
        pivot.id
      end
    end

    def is_pivoting
      !self.pivots.active.last.blank?
    end
  
    def categories
      [['ARTS','ARTS'], 
      ['COMICS','COMICS'],
      ['CRAFTS','CRAFTS'],
      ['DANCE','DANCE'],
      ['DESIGN','DESIGN'],
      ['FASHION','FASHION'],
      ['FILM & VIDEO','FILM & VIDEO'],
      ['FOOD','FOOD'],
      ['GAMES','GAMES'],
      ['JOURNALISM','JOURNALISM'],
      ['MUSIC','MUSIC'],
      ['PHOTOGRAPHY','PHOTOGRAPHY'],
      ['PUBLISHING','PUBLISHING'],
      ['TECHNOLOGY','TECHNOLOGY'],
      ['THEATER','THEATER']]
    end
  
    def stages
      [['IDEA/CONCEPT','IDEA/CONCEPT'], 
      ['PRODUCT/PROTOTYPE DEVELOPMENT','PRODUCT/PROTOTYPE DEVELOPMENT'],
      ['RENCENTLY LAUNCHED','RENCENTLY LAUNCHED'],
      ['PRE-REVENUE','PRE-REVENUE'],
      ['OPERATING W/ REVENUE','OPERATING W/ REVENUE']]
    end

    
    
    
	 #validar user
    validates :user_id, presence: true
    
    #validar description
    validates :pitch, :presence => {:message => "Must write a description"}
    
    #validar category
    validates :category, :presence => {:message => "Must select the Startup's category"}
    
    #validar country
    validates :country, :presence => {:message => "Must select the Startup's country"}
    
	#validar stage
    validates :stage, :presence => {:message => "Must select the Startup's stage"}
    
    #validar name
    validates_uniqueness_of :name, :scope => [:country], :message => "Must select a different Startup's name for that country"
    validates :name, :presence => {:message => "Must write a name"}

    #validar webpage
    VALID_URL_REGEX = /(https?:\/\/)?([\da-z\.-]+)\.?([a-z\.]{2,6})([\/\w \?=.-]*)*\.([a-z\.]{2,6})([\/\w \?=.-]*)*\/?/	
    #validates :webpage, format: { :with => VALID_URL_REGEX , message: "Must insert a valid url, www.example.com" }

    #validar videopitch
    
    #^((https?:\/\/)(player)\.(vimeo)\.(com)(\/video\/)[0-9]*)$|^((https?:\/\/)?(www)\.(youtube)\.(com)(\/embed\/)[a-z A-Z_0-9]*)$
	VALID_FORMAT_VIDEO = /((https?:\/\/)(player)\.(vimeo)\.(com)(\/video\/)[0-9]*)$|^((https?:\/\/)?(www)\.(youtube)\.(com)(\/embed\/)[a-z A-Z_0-9]*$)/
	#validates :videopitch, format: { :with => VALID_FORMAT_VIDEO , message: "http://www.youtube.com/embed/yYAb2RaSkQk" }
	#validates :videopitch, :presence => {:message => "Must insert the url's pitchvideo"}

	#validar logo
	#validates :logo, format: { :with => %r{.(gif|jpg|png)$}i, :multiline => true ,:message => "Must be a URL for GIF, JPG or PNG image.(gif/jpg/png)"}
	#validates :logo, :presence => {:message => "Must insert the url's logo"}

  def reorder_entries entry_id=nil
    self.entries.where("id>?",entry_id).each do |t|
      t.decrement!
    end
  end


end