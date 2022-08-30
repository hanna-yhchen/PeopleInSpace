//
//  ViewController.swift
//  PeopleInSpace
//
//  Created by Hanna Chen on 2022/8/30.
//

import UIKit
import Combine

class ViewController: UIViewController {

    typealias People = [String]
    typealias Craft = String

    var crafts: [Craft] = []
    var peopleByCraft: [Craft: People] = [:]
    var cancellable: AnyCancellable?

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    let cellIdentifier = "name-cell"

    override func viewDidLoad() {
        super.viewDidLoad()

        subscribe()
    }

    private func subscribe() {
        cancellable = AstrosAPI.publisher
            .map {[weak self] (astronauts: [Astronaut]) -> [Craft: People] in
                guard let self = self else { return [:] }

                var peopleByCraft: [Craft: People] = [:]

                for astronaut in astronauts {
                    let craft = astronaut.craft
                    let name = astronaut.name

                    if var people = peopleByCraft[craft] {
                        people.append(name)
                        peopleByCraft.updateValue(people, forKey: craft)
                    } else {
                        peopleByCraft.updateValue([name], forKey: craft)
                        self.crafts.append(craft)
                    }
                }

                for (craft, people) in peopleByCraft {
                    let sorted = self.sortByLastName(people)
                    peopleByCraft.updateValue(sorted, forKey: craft)
                }

                return peopleByCraft
            }
            .receive(on: DispatchQueue.main)
            .sink {[weak self] crafts in
                guard let self = self else { return }
                self.peopleByCraft = crafts
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
            }
    }

    private func sortByLastName(_ people: People) -> People {
        people.sorted { lhs, rhs in
            let lhsReversed = lhs.reversed()
            let rhsReversed = rhs.reversed()

            guard
                let lhsIndexOfSpace = lhsReversed.firstIndex(of: " "),
                let rhsIndexOfSpace = rhsReversed.firstIndex(of: " ")
            else {
                return true
            }

            let lhsIndex = lhsReversed.index(before: lhsIndexOfSpace)
            let rhsIndex = rhsReversed.index(before: rhsIndexOfSpace)

            return lhsReversed[lhsIndex] < rhsReversed[rhsIndex] ? true : false
        }
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        crafts[section]
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        crafts.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        peopleByCraft[crafts[section]]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        var content = cell.defaultContentConfiguration()

        let currentCraft = crafts[indexPath.section]
        if let people = peopleByCraft[currentCraft] {
            let name = people[indexPath.row]
            content.text = name
        }

        content.textProperties.color = UIColor(named: "LabelColor")!
        cell.contentConfiguration = content

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            var content = header.defaultContentConfiguration()
            content.textProperties.color = UIColor(named: "SecondaryBackgroundColor")!
            content.text = crafts[section]
            header.contentConfiguration = content
        }
    }
}
