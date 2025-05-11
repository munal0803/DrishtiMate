# DrishtiMate
DrishtiMate is an assistive mobile application designed to empower blind and visually impaired individuals by enabling them to recognize and locate everyday objects using their smartphone camera

@Inspiration:
Drishtimate was created to empower visually impaired individuals, helping them navigate the world with more independence. We aimed to bridge the accessibility gap by offering a tool that not only assists with daily navigation but also ensures users’ safety, creating a more inclusive environment for the blind community to thrive in.

##What it does:
Drishtimate uses the phone’s camera to detect objects in real-time with YOLOv9 and provides immediate auditory feedback to guide the user. In case of emergencies, the app alerts the user’s guardian through Firebase notifications. It’s designed to give blind individuals the confidence to move freely, knowing they are supported and safe.

##How we built it:
We used Flutter to build a cross-platform app, ensuring seamless experiences across devices. YOLOv9 was implemented for real-time object detection, known for its accuracy and speed. The backend runs on Django to manage user data, and Firebase handles real-time communication, sending emergency notifications to guardians when needed.

##Challenges we ran into:
The main challenges were optimizing YOLOv9 for mobile devices and ensuring real-time object detection worked seamlessly across various environments. Minimizing delays and optimizing background tasks, like continuous object detection and notifications, while maintaining performance was a tricky yet important challenge.

##Accomplishments that we're proud of:
We’re incredibly proud of creating a functional, intuitive app that helps visually impaired individuals navigate their surroundings with confidence. By integrating cutting-edge AI, real-time alerts, and a user-friendly Flutter interface, Drishtimate is a step towards making technology more accessible and empowering blind users.

##What we learned:
We learned how essential it is to combine advanced AI and mobile development for accessibility. The process highlighted the importance of empathy-driven design, creating intuitive features that empower users. It also deepened our understanding of how cloud services like Firebase and Django can enhance real-time capabilities.

##What's next for Drishtimate:
We plan to expand Drishtimate by adding multi-object detection, improved localization, and more personalized settings based on user preferences. Future updates will also include gesture control and voice commands to further enhance independence and safety for visually impaired users in different environments.
