//
//  ViewController.swift
//  Shambabmukly
//
//  Created by Илья Акулов on 28.08.2024.
//

import UIKit

class ViewController: UIViewController {
    
    var cells: [(String, Cell)] = [] // Используем кортеж (тип сообщения, клетка)
    var liveStreak: Int = 0
    var deadStreak: Int = 0
    
    let label = UILabel()
    let tableView = UITableView()
    let addCellButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Настройка представлений
        view.backgroundColor = #colorLiteral(red: 0.1674109101, green: 0, blue: 0.2744264007, alpha: 1)
        setupLabel()
        setupAddCellButton()
        setupTableView()
        
    }
    
    // MARK: - Setup UI
    
    private func setupLabel() {
        label.text = "Клеточное наполнение"
        label.textAlignment = .center
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        // Устанавливаем Auto Layout
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
            label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15),
            label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15),
            label.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = #colorLiteral(red: 0.1674109101, green: 0, blue: 0.2744264007, alpha: 1)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        // Устанавливаем Auto Layout
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addCellButton.topAnchor)
        ])
    }
    
    private func setupAddCellButton() {
        addCellButton.setTitle("СОТВОРИТЬ", for: .normal)
        addCellButton.backgroundColor = #colorLiteral(red: 0.3506531417, green: 0.2037386894, blue: 0.4450328946, alpha: 1)
        addCellButton.setTitleColor(.white, for: .normal)
        addCellButton.layer.cornerRadius = 4
        addCellButton.addTarget(self, action: #selector(addCellButtonTapped), for: .touchUpInside)
        addCellButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(addCellButton)
        
        // Устанавливаем Auto Layout для кнопки
        NSLayoutConstraint.activate([
            addCellButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            addCellButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            addCellButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            addCellButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    //    // MARK: - Button Action
    @objc func addCellButtonTapped() {
        let newCell = createNewCell()
        cells.append((newCell.isAlive ? "Живая клетка" : "Мёртвая клетка", newCell))
        updateStreaks(for: newCell)
        checkCellSurvival()
        tableView.reloadData()
    }
    
    //    // MARK: - Cell Creation Logic
    private func createNewCell() -> Cell {
        if liveStreak == 3 {
            cells.append(("Жизнь зарождается", Cell(isAlive: true)))
            return Cell(isAlive: true)
        } else if deadStreak == 3 {
            // Убить последнюю живую клетку, если она есть
            if let lastCellIndex = cells.lastIndex(where: { $0.1.isAlive }) {
                cells[lastCellIndex].1.isAlive = false
                cells.append(("Жизнь рядом умирает", cells[lastCellIndex].1))
            }
            return Cell(isAlive: false)
        } else {
            // Равновероятное создание живой или мёртвой клетки
            return Cell(isAlive: Bool.random())
        }
    }
    
    private func checkCellSurvival() {
        // Проверяем последние 3 клетки для наличия условий умирания и рождения
        let count = cells.count
        if count >= 4 {
            let lastThreeCells = Array(cells[(count - 4)...(count - 2)])
            let aliveCount = lastThreeCells.filter { $0.1.isAlive }.count
            let deadCount = lastThreeCells.filter { !$0.1.isAlive }.count
            
            if aliveCount == 3 {
                cells.append(("Жизнь зарождается", Cell(isAlive: true)))
            }
            
            if deadCount == 3 {
                if let lastAliveIndex = cells.lastIndex(where: { $0.1.isAlive }) {
                    cells[lastAliveIndex].1.isAlive = false
                    cells.append(("Жизнь рядом умирает", cells[lastAliveIndex].1))
                }
            }
        }
    }
    
    //    // MARK: - Streaks Management
    private func updateStreaks(for newCell: Cell) {
        if newCell.isAlive {
            liveStreak += 1
            deadStreak = 0
        } else {
            deadStreak += 1
            liveStreak = 0
        }
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let cellData = cells[indexPath.row]
        cell.textLabel?.text = cellData.0 // Используем тип сообщения
        cell.textLabel?.textAlignment = .center
//        cell.backgroundColor = .systemGray
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        // Устанавливайте свои изображения в зависимости от статуса клетки
        let imageName = cellData.1.isAlive ? "alive_cell_image" : "dead_cell_image"
        imageView.image = UIImage(named: imageName)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Установка изображения в ячейку
        cell.contentView.addSubview(imageView) // Добавляем изображение как подвид
        let backgroundView = UIView()
        backgroundView.backgroundColor = #colorLiteral(red: 0.1674109101, green: 0, blue: 0.2744264007, alpha: 1)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(backgroundView)
        // Настройка ограничений для изображения
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 15),
            imageView.heightAnchor.constraint(equalToConstant: 40), // высота изображения
            imageView.widthAnchor.constraint(equalToConstant: 40) // ширина изображения
        ])
        NSLayoutConstraint.activate([
            backgroundView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            backgroundView.leftAnchor.constraint(equalTo: cell.contentView.leftAnchor),
            backgroundView.rightAnchor.constraint(equalTo: cell.contentView.rightAnchor),
            backgroundView.heightAnchor.constraint(equalToConstant: 5)
        ])
        
        // Обрезка углов
        cell.layer.cornerRadius = 8
        cell.layer.masksToBounds = true
        
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
}
