-- =====================================================
-- BANCO DE DADOS: ATACADÃO DAS CESTAS (B2B)
-- =====================================================

-- CRIAR BANCO DE DADOS
CREATE DATABASE IF NOT EXISTS atacadao_cestas;
USE atacadao_cestas;

-- =====================================================
-- 1. TABELA: CATEGORIAS DE PRODUTOS
-- =====================================================
CREATE TABLE categorias (
    id_categoria INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    icone VARCHAR(100),
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 2. TABELA: FORNECEDORES
-- =====================================================
CREATE TABLE fornecedores (
    id_fornecedor INT PRIMARY KEY AUTO_INCREMENT,
    razao_social VARCHAR(200) NOT NULL,
    cnpj VARCHAR(18) UNIQUE NOT NULL,
    nome_fantasia VARCHAR(200),
    email VARCHAR(150),
    telefone VARCHAR(20),
    endereco TEXT,
    ativo BOOLEAN DEFAULT TRUE,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 3. TABELA: PRODUTOS
-- =====================================================
CREATE TABLE produtos (
    id_produto INT PRIMARY KEY AUTO_INCREMENT,
    codigo_barra VARCHAR(50) UNIQUE,
    nome VARCHAR(200) NOT NULL,
    descricao TEXT,
    id_categoria INT,
    id_fornecedor INT,
    preco_compra DECIMAL(10,2),
    preco_venda_atacado DECIMAL(10,2) NOT NULL,
    preco_venda_varejo DECIMAL(10,2),
    estoque_minimo INT DEFAULT 0,
    estoque_atual INT DEFAULT 0,
    unidade_medida VARCHAR(20) DEFAULT 'UN',
    peso DECIMAL(8,2),
    ativo BOOLEAN DEFAULT TRUE,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria),
    FOREIGN KEY (id_fornecedor) REFERENCES fornecedores(id_fornecedor)
);

-- =====================================================
-- 4. TABELA: CESTAS (COMPOSIÇÃO)
-- =====================================================
CREATE TABLE cestas (
    id_cesta INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(150) NOT NULL,
    descricao TEXT,
    preco_cesta DECIMAL(10,2) NOT NULL,
    quantidade_itens INT,
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 5. TABELA: ITENS DA CESTA
-- =====================================================
CREATE TABLE itens_cesta (
    id_item_cesta INT PRIMARY KEY AUTO_INCREMENT,
    id_cesta INT,
    id_produto INT,
    quantidade DECIMAL(8,2),
    preco_unitario DECIMAL(10,2),
    FOREIGN KEY (id_cesta) REFERENCES cestas(id_cesta),
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto)
);

-- =====================================================
-- 6. TABELA: TIPOS DE CLIENTES
-- =====================================================
CREATE TABLE tipos_cliente (
    id_tipo INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    desconto_percentual DECIMAL(5,2) DEFAULT 0,
    pedido_minimo DECIMAL(10,2) DEFAULT 0,
    ativo BOOLEAN DEFAULT TRUE
);

-- =====================================================
-- 7. TABELA: CLIENTES (B2B)
-- =====================================================
CREATE TABLE clientes (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    razao_social VARCHAR(200) NOT NULL,
    cnpj VARCHAR(18) UNIQUE NOT NULL,
    nome_fantasia VARCHAR(200),
    email VARCHAR(150) NOT NULL,
    telefone VARCHAR(20),
    celular VARCHAR(20),
    id_tipo INT,
    endereco TEXT,
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    uf CHAR(2),
    cep VARCHAR(10),
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ativo BOOLEAN DEFAULT TRUE,
    data_ultima_compra DATE,
    credito_disponivel DECIMAL(10,2) DEFAULT 0,
    FOREIGN KEY (id_tipo) REFERENCES tipos_cliente(id_tipo)
);

-- =====================================================
-- 8. TABELA: PEDIDOS
-- =====================================================
CREATE TABLE pedidos (
    id_pedido INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT,
    numero_pedido VARCHAR(50) UNIQUE NOT NULL,
    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_entrega DATE,
    valor_total DECIMAL(12,2) NOT NULL,
    valor_desconto DECIMAL(10,2) DEFAULT 0,
    valor_final DECIMAL(12,2) NOT NULL,
    forma_pagamento ENUM('PIX', 'BOLETO', 'CARTAO', 'CREDIARIO') NOT NULL,
    status ENUM('PENDENTE', 'APROVADO', 'EM_PREPARACAO', 
                'EM_TRANSITO', 'ENTREGUE', 'CANCELADO') DEFAULT 'PENDENTE',
    observacoes TEXT,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

-- =====================================================
-- 9. TABELA: ITENS DO PEDIDO
-- =====================================================
CREATE TABLE itens_pedido (
    id_item_pedido INT PRIMARY KEY AUTO_INCREMENT,
    id_pedido INT,
    id_produto INT,
    quantidade DECIMAL(8,2),
    preco_unitario DECIMAL(10,2),
    valor_total_item DECIMAL(12,2),
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido),
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto)
);

-- =====================================================
-- 10. TABELA: MOVIMENTAÇÕES DE ESTOQUE
-- =====================================================
CREATE TABLE movimentacoes_estoque (
    id_movimentacao INT PRIMARY KEY AUTO_INCREMENT,
    id_produto INT,
    tipo_movimentacao ENUM('ENTRADA', 'SAIDA') NOT NULL,
    quantidade DECIMAL(8,2),
    id_pedido INT NULL,
    data_movimentacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    observacao VARCHAR(255),
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto),
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
);

-- =====================================================
-- 11. TABELA: CONFIGURAÇÕES DO SISTEMA
-- =====================================================
CREATE TABLE configuracoes (
    id_config INT PRIMARY KEY AUTO_INCREMENT,
    nome_parametro VARCHAR(100) UNIQUE NOT NULL,
    valor_parametro TEXT,
    descricao TEXT
);

-- =====================================================
-- DADOS INICIAIS
-- =====================================================

-- 1. Tipos de Clientes
INSERT INTO tipos_cliente (nome, desconto_percentual, pedido_minimo) VALUES
('VAREJISTA', 5.00, 200.00),
('SUPERMERCADO', 10.00, 500.00),
('REDE DE MERCADOS', 15.00, 1000.00),
('DISTRIBUIDOR', 20.00, 2000.00);

-- 2. Categorias
INSERT INTO categorias (nome, descricao) VALUES
('FRUTAS', 'Frutas frescas e secas'),
('VERDURAS', 'Verduras e legumes'),
('GRÃOS', 'Arroz, feijão, macarrão'),
('LACTEOS', 'Leite, queijo, iogurte'),
('CARNES', 'Carnes bovinas, suínas, aves'),
('BEBIDAS', 'Água, sucos, refrigerantes'),
('HIGIENE', 'Sabonetes, shampoos, papel higiênico');

-- 3. Fornecedores
INSERT INTO fornecedores (razao_social, cnpj, nome_fantasia, email) VALUES
('FRUTAS DO VALE LTDA', '12.345.678/0001-90', 'Frutas Vale', 'contato@frutasvale.com'),
('GRÃOS SAUDÁVEIS', '98.765.432/0001-12', 'Grãos Saudáveis', 'vendas@graossaudaveis.com'),
('LACTEOS PREMIUM', '11.222.333/0001-44', 'Lácteos Premium', 'comercial@lacteos.com');

-- 4. Produtos
INSERT INTO produtos (codigo_barra, nome, id_categoria, id_fornecedor, preco_venda_atacado, estoque_atual) VALUES
('7891234567890', 'Arroz Agulhinha 5kg', 3, 2, 12.50, 500),
('7890987654321', 'Feijão Carioca 1kg', 3, 2, 5.80, 300),
('1234567890123', 'Maçã Fuji kg', 1, 1, 4.20, 200),
('4567891234567', 'Leite Integral 1L', 4, 3, 3.50, 400),
('9876543210987', 'Sabonete Dove 90g', 7, 1, 1.20, 1000);

-- 5. Cestas
INSERT INTO cestas (nome, descricao, preco_cesta, quantidade_itens) VALUES
('Cesta Básica Essencial', 'Para famílias pequenas', 45.00, 5),
('Cesta Familiar Completa', 'Para famílias médias', 85.00, 8),
('Cesta Premium', 'Produtos selecionados', 120.00, 10);

-- 6. Itens da Cesta (Exemplo)
INSERT INTO itens_cesta (id_cesta, id_produto, quantidade, preco_unitario) VALUES
(1, 1, 2.00, 12.50),  -- 2 sacos arroz
(1, 2, 2.00, 5.80),   -- 2 kg feijão
(1, 3, 1.00, 4.20),   -- 1 kg maçã
(1, 4, 2.00, 3.50);   -- 2 L leite

-- 7. Cliente Exemplo
INSERT INTO clientes (razao_social, cnpj, nome_fantasia, email, id_tipo) VALUES
('MERCADO DO POVO LTDA', '12.345.678/0001-23', 'Mercado do Povo', 'compras@mercado.com', 1);

-- 8. Configurações
INSERT INTO configuracoes (nome_parametro, valor_parametro, descricao) VALUES
('taxa_entrega', '15.00', 'Taxa fixa de entrega'),
('dias_credito', '30', 'Prazo máximo de crédito'),
('percentual_max_credito', '50', '% máximo do crédito por pedido');