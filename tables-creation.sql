-- Table: Pivos
CREATE TABLE pivots (
    id SERIAL PRIMARY KEY,
    vetor_minucias float[][]
);

--Table: Minucias
CREATE TABLE minucias (
    id SERIAL PRIMARY KEY,
    vetor_minucias float[][],
	distancepivot1 float,
	distancepivot2 float,
	distancepivot3 float
)

-- Table: pessoa
CREATE TABLE pessoa (
    pessoa_id SERIAL PRIMARY KEY,
    nome VARCHAR(50),
    data_nascimento TIMESTAMP,
    sexo VARCHAR(15),
    nome_responsavel VARCHAR(50),
    telefone_responsavel VARCHAR(20),
    rua VARCHAR(50),
    bairro VARCHAR(50),
    numero INTEGER,
    cidade VARCHAR(50),
    estado VARCHAR(25),
    pais VARCHAR(30)
);

-- Table: dedos
CREATE TABLE dedos (
    dedo_id SMALLINT PRIMARY KEY,
    nome_dedo VARCHAR(15),
    mao VARCHAR(10)
);

-- Table: extracoes
CREATE TABLE extracoes (
    extracao_id SERIAL PRIMARY KEY,
    tipo_extracao VARCHAR(25),
    resultado_extracao BYTEA
);

-- Table: sensor
CREATE TABLE sensor (
    sensor_id INTEGER PRIMARY KEY,
    marca VARCHAR(30),
    modelo VARCHAR(30),
    resolucao VARCHAR(30),
    tipo VARCHAR(50),
    valor_serial VARCHAR(50)
);

-- Table: imagem_digital
CREATE TABLE imagem_digital (
    imagem_id INTEGER PRIMARY KEY,
    imagem_original BYTEA,
    extracoes INTEGER REFERENCES extracoes(extracao_id),
    mapa_de_minucias_id INTEGER REFERENCES minucias(id),
    sensor_id INTEGER REFERENCES sensor(sensor_id),
    dedo_id INTEGER REFERENCES dedos(dedo_id)
);

-- Table: recoleta
CREATE TABLE recoleta (
    recoleta_id SERIAL PRIMARY KEY,
    imagem_id INTEGER REFERENCES imagem_digital(imagem_id),
    local_de_coleta VARCHAR(50),
    data TIMESTAMP
);

-- Table: coleta_inicial
CREATE TABLE coleta_inicial (
    coleta_id SERIAL PRIMARY KEY,
    pessoa_id INTEGER REFERENCES pessoa(pessoa_id),
    horario_coleta TIMESTAMP,
    imagem_id INTEGER REFERENCES imagem_digital(imagem_id),
    peso INTEGER,
    altura INTEGER,
    tomou_banho BOOLEAN,
    semanas_de_gestacao INTEGER,
    eh_recem_nascido BOOLEAN,
    recoleta INTEGER REFERENCES recoleta(recoleta_id)
);