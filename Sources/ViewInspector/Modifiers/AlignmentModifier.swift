//
// Created by René Pirringer on 06.04.21.
//

import Foundation
import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {

	func alignment() throws -> Alignment? {
		return content.medium.alignment
	}

}
