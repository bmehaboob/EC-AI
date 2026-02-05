-- PropertyCase table
CREATE TABLE IF NOT EXISTS property_cases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id VARCHAR(255),
  district VARCHAR(255),
  sro VARCHAR(255),
  search_params JSONB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ECEntry table (transactions)
CREATE TABLE IF NOT EXISTS ec_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  case_id UUID REFERENCES property_cases(id),
  doc_number VARCHAR(255),
  doc_year INT,
  reg_date DATE,
  nature_of_doc VARCHAR(255),
  parties TEXT,
  consideration DECIMAL,
  schedule_text TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- BoundaryVersion table
CREATE TABLE IF NOT EXISTS boundary_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ec_entry_id UUID REFERENCES ec_entries(id),
  north_text TEXT,
  south_text TEXT,
  east_text TEXT,
  west_text TEXT,
  extraction_confidence FLOAT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
